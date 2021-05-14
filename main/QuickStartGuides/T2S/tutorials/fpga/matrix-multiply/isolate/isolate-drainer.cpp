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
ImageParam a(TYPE, 2);
ImageParam b(TYPE, 2);

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

    // Isolate the result c to an output pipeline c --> drainer.
    // The arguments of the new function will be generatd automatically. One need set the place.
    Func drainer("drainer", Place::Device);

    // One isolated, drainer inherits the result c's args, P_c, which has less loops than the
    // systolic array (the reduction loops kkk, kk and k are gone). For this new loop structure, do
    // space-time transform with jjj and iii as the space loops, consistent with the systolic array.
    c.isolate_consumer(drainer);
    drainer.space_time_transform(jjj, iii);

    // Return the (unique) output function The compiler will be able to find all the other functions from it.
    return drainer;
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


    Target target = get_host_target();     // Get the CPU host
    target.set_feature(Target::IntelFPGA); // To execute on an Intel FPGA device attached to the host.
    Func mm = matrix_multiply();           // Get the compute.

#ifdef COMPILE_ONLY
    mm.compile_jit(target);
#else
    // Invoke the T2S compiler to compile and offload the compute to the FPGA. Copy the result back to the host.
    Buffer<float> result(JJJ, III, JJ, II, OUTERMOST_J, OUTERMOST_I);
    mm.realize(result, target);
    result.copy_to_host();

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



