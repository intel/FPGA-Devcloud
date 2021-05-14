// The only header file needed for including T2S.
#include "Halide.h"

// For printing output
#include <stdio.h>

// For validation of results.
#include <assert.h>

using namespace Halide;
using namespace std;

// Input matrices: A(K, I)  and B(J, K). Following Halide's convention, they are in column-major format.
#define I 1024
#define J 1024
#define K 256

// Input parameters: a and b are 2D float32 matrices.
#define TYPE Float(32)
ImageParam a("a", TYPE, 2);
ImageParam b("b", TYPE, 2);

// Implementation of the compute.
Func matrix_multiply() {
    // Loop variables
    Var  k("k"), j("j"), i("i");

    // UREs. All are recursive functions, and need signatures to be declared. An exception is c, the function
    // for the final results, which is not really a recursive Func, and declaring its place is enough.
    Func A("A", TYPE, {k, j, i}, Place::Device), // Name (optional), return type, arguments and Place.
         B("B", TYPE, {k, j, i}, Place::Device),
         C("C", TYPE, {k, j, i}, Place::Device),
         c("c", Place::Device);

    // Recursively compute.
    A(k, j, i) = select(j == 0, a(k, i), A(k, j - 1, i));
    B(k, j, i) = select(i == 0, b(j, k), B(k, j, i - 1));
    C(k, j, i) = select(k == 0, 0, C(k - 1, j, i)) + A(k, j, i) * B(k, j, i);

    // Take the final output
    c(j, i) = select(k == K - 1, C(k, j, i));

    // Put all the UREs inside the same loop nest. Now the first URE (A) represents all the UREs.
    A.merge_ures(B, C, c);

    // Explicitly set the loop bounds
    A.set_bounds(k, 0, K, j, 0, J, i, 0, I);


    // Return the (unique) output func. Compiler will be able to find other functions from it.
    return c;
}

int main() {
    // Step 1: Set input. Random data here for example:
    Buffer<float> ina(K, I), inb(J, K);
    for (size_t i = 0; i < I; i++) {
        for (size_t k = 0; k < K; k++) {
            ina(k, i) = k + i;
        }
    }
    for (size_t k = 0; k < K; k++) {
        for (size_t j = 0; j < J; j++) {
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
    Buffer<float> result(J, I);
    mm.realize(result, target);
    result.copy_to_host();

    // Step 3: Validate the results
    for (size_t i = 0; i < I; i++) {
        for (size_t j = 0; j < J; j++) {
            float golden = 0.0f;
            for (size_t k = 0; k < K; k++) {
                golden += ina(k, i) * inb(j, k);
            }
            assert(fabs(golden - result(j, i)) < 0.005*fabs(golden));
        }
    }
#endif
    cout << "Success!\n";
    return 0;
}



