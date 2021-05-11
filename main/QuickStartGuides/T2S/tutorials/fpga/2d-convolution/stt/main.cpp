// The only header file needed for including T2S.

#include "Halide.h"



// For printing output

#include <stdio.h>



// For validation of results.

#include <assert.h>



#include "../util.h"



using namespace Halide;

using namespace std;



#define O 8

#define I 8

#define C 16

#define R 16

#define P 3

#define Q 3



#define TYPE int

#define HALIDE_TYPE Int(32)



int main(void) {

    ImageParam x(type_of<TYPE>(), 3);

    ImageParam w(type_of<TYPE>(), 4);



// Macros: for convenient use.

#define A                      q,     p,     r,     c,         i,     o

#define A_r_minus_1            q,     p,     r - 1, c,         i,     o

#define A_q_minus_1            q - 1, p,     r,     c,         i,     o

#define A_p_minus_1            q,     p - 1, r,     c,         i,     o

#define A_i_minus_1            q,     p,     r,     c,         i - 1, o

#define A_no_p_q_i                           r,     c,                o



#define FUNC_DECL HALIDE_TYPE, {A}, Place::Device



    Var A;

    Func X(FUNC_DECL), W(FUNC_DECL), H(FUNC_DECL), V(FUNC_DECL), Z(FUNC_DECL), // A recurrent Func needs declare return type, args, and place.

         z(Place::Device);                                                             // A non-recurrent Func needs declare only its place.



    X(A) = x(c + q, r + p, i);

    W(A) = select(c == 0 && r == 0, w(q, p, i, o), W(A_r_minus_1));

    H(A) = select(q == 0, 0, H(A_q_minus_1)) + X(A) * W(A);

    V(A) = select(q == Q - 1, select(p == 0, 0, V(A_p_minus_1)) + H(A), 0 /* arbitrary value, not contributing to output anyway*/);

    Z(A) = select(q == Q - 1 && p == P - 1, select(i == 0, 0, Z(A_i_minus_1)) + V(A), 0 /* arbitrary value, not contributing to output anyway*/);

    z(A_no_p_q_i) = select(q == Q - 1 && p == P - 1 && i == I - 1, Z(A));



    X.merge_ures(W, H, V, Z, z) // Put all the UREs into the same loop nest

     .set_bounds(p, 0, P, q, 0, Q)

     .set_bounds(r, 0, R, c, 0, C)

     .set_bounds(o, 0, O, i, 0, I);



    X.space_time_transform(q, p);



    // Generate input and run.

    Buffer<TYPE> inx = new_data_3D<TYPE, C + Q - 1, R + P - 1, I>(SEQUENTIAL); // or RANDOM

    Buffer<TYPE> inw = new_data_4D<TYPE, Q, P, I, O>(SEQUENTIAL);              // or RANDOM

    x.set(inx);

    w.set(inw);

    Target target = get_host_target();

    target.set_feature(Target::IntelFPGA);

    target.set_feature(Target::Debug);

    Buffer<TYPE> results = z.realize({R, C, O}, target);

    void check(const Buffer<TYPE> &, const Buffer<TYPE> &, const Buffer<TYPE> &results);

    check(inx, inw, results);

    cout << "Success!\n";

    return 0;

}



void check(const Buffer<TYPE> &x, const Buffer<TYPE> &w, const Buffer<TYPE> &results) {

    Buffer<TYPE> golden(R, C, O);

    for (int o = 0; o < O; o++) {

        for (int r = 0; r < R; r++) {

            for (int c = 0; c < C; c++) {

                golden(r, c, o) = 0;

                for (int i = 0; i < I; i++) {

                    for (int p = 0; p < P; p++) {

                        for (int q = 0; q < Q; q++) {

                            golden(r, c, o) += x(c + q, r + p, i) * w(q, p, i, o);

                        }

                    }

                }

            }

        }

    }

    check_equal_3D<TYPE>(golden, results);

}


