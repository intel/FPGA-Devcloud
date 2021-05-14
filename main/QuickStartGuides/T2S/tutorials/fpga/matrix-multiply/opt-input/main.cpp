// The only header file needed for including T2S.
#include "Halide.h"

// For sizes of the input matrices and systolic array
#include "../sizes.h"

// For printing output
#include <stdio.h>

// For validation of results.
#include <assert.h>

using namespace Halide;
using namespace std;

/* Implement the following compute:

   // Enumerate tiles of the output matrix c.
   for i in [0, I)
     for j in [0, J)
       for k in [0, K)
         for kk in [0, KK)
           for ii in [0, II)
             for jj in [0, JJ)
               for iii in [0, III)
                 for jjj in [0, JJJ)
                   for kkk in [0, KKK)
                     i' = iii + III * ii + III * II * i
                     j' = jjj + JJJ * jj + JJJ * JJ * j
                     k' = kkk + KKK * kk + KKK * KK * k
                     c(jjj, iii, jj, ii, j, i) += a(k', i') * b(j', k')

    The outermost loops' extents, I, J, and K, are determined by the actual sizes of the input matrices, which can be
    unknown to the compiler. The other loops' extents are static constants.
*/

// Now the outermost loops' extents are determined by the input matrices' sizes.
#define I    (a.dim(1).extent() / (III * II))
#define J    (b.dim(0).extent() / (JJJ * JJ))
#define K    (a.dim(0).extent() / (KKK * KK))

// Input matrix a and b are 2-dimensional matrices of TYPE (float32).
#define TYPE Float(32)
ImageParam   a(TYPE, 2);
ImageParam   b(TYPE, 2);

// Implementation of the compute.
Func matrix_multiply() {
    // Macros for the convenience of writing UREs.
    // Iterations:
    #define P             kkk,           jjj,     iii,     jj, ii, kk,          k,     j, i
    #define P_iii_minus_1 kkk,           jjj,     iii - 1, jj, ii, kk,          k,     j, i // To be used only when iii != 0
    #define P_jjj_minus_1 kkk,           jjj - 1, iii,     jj, ii, kk,          k,     j, i // T0 be used only when jjj != 0
    #define P_kkk_minus_1 kkk - 1,       jjj,     iii,     jj, ii, kk,          k,     j, i // To be used only when kkk != 0
    #define P_kk_minus_1  kkk + KKK - 1, jjj,     iii,     jj, ii, kk - 1,      k,     j, i // To be used only when kkk == 0 and kk != 0
    #define P_k_minus_1   kkk + KKK - 1, jjj,     iii,     jj, ii, kk + KK - 1, k - 1, j, i // To be used only when kkk == 0, kk == 0 and k != 0
    #define P_c                          jjj,     iii,     jj, ii,                     j, i // Dimensions for the output
    // Linearized addresses:
    #define total_i       (iii + III * ii + III * II * i)
    #define total_j       (jjj + JJJ * jj + JJJ * JJ * j)
    #define total_k       (kkk + KKK * kk + KKK * KK * k)

    // Loop variables
    Var  kkk("kkk"), jjj("jjj"), iii("iii"), kk("kk"), jj("jj"), ii("ii"), k("k"), j("j"), i("i");

    // UREs. All are recursive functions, and need signatures to be declared. An exception is c, the function
    // for the final results, which is not really a recursive Func, and declaring its place is enough.
    Func A("A", TYPE, {P}, Place::Device), // Name (optional), return type, arguments and Place.
         B("B", TYPE, {P}, Place::Device),
         C("C", TYPE, {P}, Place::Device),
         c("c", Place::Device);
    A(P)   = select(jjj == 0, a(total_k, total_i), A(P_jjj_minus_1));
    B(P)   = select(iii == 0, b(total_j, total_k), B(P_iii_minus_1));
    C(P)   = select((kkk == 0) && kk == 0 && k == 0, 0,
                    select(kkk == 0, select(kk == 0, C(P_k_minus_1), C(P_kk_minus_1)), C(P_kkk_minus_1))
                   ) + A(P) * B(P);
    c(P_c) = select((kkk == KKK - 1) && (kk == KK -1) && (k == K - 1), C(P));

    // Put all the UREs inside the same loop nest. Now the first URE (A) represents all the UREs.
    A.merge_ures(B, C, c);

    // Explicitly set the loop bounds
    A.set_bounds(kkk, 0, KKK, jjj, 0, JJJ, iii, 0, III)
     .set_bounds(kk,  0, KK,  jj,  0, JJ,  ii,  0, II)
     .set_bounds(k,   0, K,   j,   0, J,   i,   0, I);

    A.space_time_transform(kkk, jjj, iii)
     .vectorize(kkk);

    // Isolate out the I/O network.
    // The arguments of the new functions will be generatd automatically. One need set the places.
    Func aSerializer("aSerializer", Place::Host), aLoader("aLoader", Place::Device),
         aFeeder("aFeeder", Place::Device), bSerializer("bSerializer", Place::Host),
         bLoader("bLoader", Place::Device), bFeeder("bFeeder", Place::Device),
         drainer("drainer", Place::Device), collector("collector", Place::Device),
         unloader("unloader", Place::Device), deserializer("deserializer", Place::Host);

    // Isolate the loading of matrix a into a pipeline: aSerializer --> aLoader --> aFeeder
    A.isolate_producer_chain(a, aSerializer, aLoader, aFeeder);

    // Isolate the loading of matrix b to another pipeline: bSerializer --> bLoader --> bFeeder
    A.isolate_producer_chain(b, bSerializer, bLoader, bFeeder);

    // Isolate the result c to an output pipeline c --> drainer --> collector --> unloader --> deserializer.
    // Here we first isolate drainer. It inherits the result c's args, P_c, which has less loops than the
    // systolic array (the reduction loops kkk, kk and k are gone). For this new loop structure, do
    // space-time transform with jjj and iii as the space loops, consistent with the systolic array.
    c.isolate_consumer(drainer);
    drainer.space_time_transform(jjj, iii);
    // Isolate the other functions in the output pipeline. They have the same loop structure as drainer.
    drainer.isolate_consumer_chain(collector, unloader, deserializer);

    // Optimize the I/O network.

    // The minimum number of registers on channels. Each channel is between two device functions. One may
    // need tune the number for each channel so that reading of the channel is not a performance bottlneck.
    #define CH_DEPTH    256
    #define c_CH_DEPTH  II * JJ // Each PE in the systolic array produces II * JJ elements in the current
                                // tile of the output matrix. Make the channel that deep so as a PE can
                                // drain all its results to the channel and continue work for the next tile.

    // On the host side, we can remove all j loops since matrix a has no dimension related with them.
    // Our runtime will send the resulting data, which are the serialized values of matrix a, into the device
    // memory. Because the resulting data will be located in memory, where the same data can be loaded as many
    // time aLoader wants, the removal of these j dimensions from aSerializer does not affect aLoader at all.
    aSerializer.remove(jjj, jj, j);

    // Load from the device memory the matrix a's values that are needed for computing 1 output tile only once.
    aLoader.remove(jjj, jj);
    // Insert some minimum number of registers on the output channel of aLoader to effectively decouple aLoader
    // from its consumer (aFeeder).
    aLoader.min_depth(CH_DEPTH);

    // Since aLoader sends less data by removing its jjj and jj loop, in aFeeder, a buffer has to be created, so
    // that the same data can be read from the buffer multiple times. The buffer must be inserted at a loop level
    // (e.g. ii or k) that encloses the two removed loops in aLoader.
    aFeeder.buffer(aLoader, k);
    // For better scalability, scatter the data vertically across the aFeeder PEs.
    aFeeder.scatter(aLoader, iii);
    // Insert some minimum number of registers on the output channel of aFeeder to effectively decouple aFeeder
    // from its consumer (the systolic array).
    aFeeder.min_depth(CH_DEPTH);

    // The input path for matrix b is optimized similarly to that for matrix a.
    bSerializer.remove(iii, ii, i);
    bLoader.remove(iii, ii).min_depth(CH_DEPTH);
    bFeeder.buffer(bLoader, k).scatter(bLoader, jjj).min_depth(CH_DEPTH);

    // Return the (unique) output function The compiler will be able to find all the other functions from it.
    return deserializer;
}

int main() {
    // Step 1: Set input. Random data here for example:
    const int TOTAL_I = III * II * OUTERMOST_I;
    const int TOTAL_J = JJJ * JJ * OUTERMOST_J;
    const int TOTAL_K = KKK * KK * OUTERMOST_K;
    Buffer<float> ina(TOTAL_K, TOTAL_I), inb(TOTAL_J, TOTAL_K);
    for (size_t i = 0; i < TOTAL_I; i++) {
        for (size_t k = 0; k < TOTAL_K; k++) {
            ina(k, i) = k + i;
        }
    }
    for (size_t k = 0; k < TOTAL_K; k++) {
        for (size_t j = 0; j < TOTAL_J; j++) {
            inb(j, k) = j - k;
        }
    }
    // Set the input parameter a/b as the actual input ina/inb.
    a.set(ina);
    b.set(inb);

    // Step 2: Run
    Target target = get_host_target();     // Get the CPU host
    target.set_feature(Target::IntelFPGA); // To execute on an Intel FPGA device attached to the host.
    Func mm = matrix_multiply();           // Get the compute.

#ifdef COMPILE_ONLY
    mm.compile_jit(target);
#else
    // Invoke the T2S compiler to compile and offload the compute to the FPGA. Copy the result back to the host.
    Buffer<float> result(JJJ, III, JJ, II, OUTERMOST_J, OUTERMOST_I);
    mm.realize(result, target);
    // No need to copy the result from device to host, because deserializer is on the host.

    // Step 3: Validate the results
    for (size_t i = 0; i < OUTERMOST_I; i++) {
        for (size_t j = 0; j < OUTERMOST_J; j++) {
            for (size_t ii = 0; ii < II; ii++) {
                for (size_t jj = 0; jj < JJ; jj++) {
                    for (size_t iii = 0; iii < III; iii++) {
                        for (size_t jjj = 0; jjj < JJJ; jjj++) {
                            size_t i1 = iii + III * ii + III * II * i;
                            size_t j1 = jjj + JJJ * jj + JJJ * JJ * j;
                            float golden = 0.0f;
                            for (size_t k1 = 0; k1 < TOTAL_K; k1++) {
                                golden += ina(k1, i1) * inb(j1, k1);
                            }
                            assert(fabs(golden - result(jjj, iii, jj, ii, j, i)) < 0.005*fabs(golden));
                        }
                    }
                }
            }
        }
    }
#endif
    cout << "Success!\n";
    return 0;
}



