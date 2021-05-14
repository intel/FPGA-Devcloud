// The only header file needed for including T2S.

#include "Halide.h"



// For printing output

#include <stdio.h>



// For validation of results.

#include <assert.h>



#include "../util.h"



using namespace Halide;

using namespace std;



#define OUTO 2

#define OUTC 2

#define OUTR 2

#define OUTI 2

#define OO 4

#define CC 8

#define RR 8

#define Q 3

#define P 3

#define II 4



#define TYPE int

#define HALIDE_TYPE Int(32)



int main(void) {

    ImageParam x(type_of<TYPE>(), 3);

    ImageParam w(type_of<TYPE>(), 4);



// Macros: for convenient use.

#define A                      ii,          q,     p,     rr,     cc, oo, outi,     outr, outc, outo

#define A_rr_minus_1           ii,          q,     p,     rr - 1, cc, oo, outi,     outr, outc, outo

#define A_q_minus_1            ii,          q - 1, p,     rr,     cc, oo, outi,     outr, outc, outo

#define A_p_minus_1            ii,          q,     p - 1, rr,     cc, oo, outi,     outr, outc, outo

#define A_ii_minus_1           ii - 1,      q,     p,     rr,     cc, oo, outi,     outr, outc, outo

#define A_outi_minus_1         ii + II - 1, q,     p,     rr,     cc, oo, outi - 1, outr, outc, outo

#define A_no_p_q_i                                        rr,     cc, oo,           outr, outc, outo



#define FUNC_DECL HALIDE_TYPE, {A}, Place::Device



    Var A;

    Func X(FUNC_DECL), W(FUNC_DECL), H(FUNC_DECL), V(FUNC_DECL), Z(FUNC_DECL), // A recurrent Func needs declare return type, args, and place.

         z(Place::Device);                                                             // A non-recurrent Func needs declare only its place.



    X(A) = x(outc * CC + cc + q, outr * RR + rr + p, ii + outi * II);

    W(A) = select(cc == 0 && rr == 0, w(q, p, ii + outi * II, outo * OO + oo), W(A_rr_minus_1));

    H(A) = select(q == 0, 0, H(A_q_minus_1)) + X(A) * W(A);

    V(A) = select(q == Q - 1, select(p == 0, 0, V(A_p_minus_1)) + H(A), 0 /* arbitrary value, not contributing to output anyway*/);

    Z(A) = select(q == Q - 1 && p == P - 1, select(ii == 0 && outi == 0, 0, select(ii == 0, Z(A_outi_minus_1), Z(A_ii_minus_1))) + V(A), 0 /* arbitrary value, not contributing to output anyway*/);

    z(A_no_p_q_i) = select(q == Q - 1 && p == P - 1 && ii == II - 1 && outi == OUTI - 1, Z(A));



    X.merge_ures(W, H, V, Z, z) // Put all the UREs into the same loop nest

     .set_bounds(ii, 0, II, p, 0, P, q, 0, Q)

     .set_bounds(rr, 0, RR, cc, 0, CC, oo, 0, OO)

     .set_bounds(outi, 0, OUTI, outr, 0, OUTR, outc, 0, OUTC, outo, 0, OUTO);



      X.space_time_transform(ii, q, p);



  //  X.vectorize(ii);



    // Generate input and run.

    Buffer<TYPE> inx = new_data_3D<TYPE, OUTC * CC + Q - 1, OUTR * RR + P - 1, OUTI * II>(SEQUENTIAL); //or RANDOM

    Buffer<TYPE> inw = new_data_4D<TYPE, Q, P, OUTI * II, OUTO * OO>(SEQUENTIAL);                      //or RANDOM

    x.set(inx);

    w.set(inw);

    Target target = get_host_target();

    target.set_feature(Target::IntelFPGA);

    target.set_feature(Target::Debug);

    Buffer<TYPE> results = z.realize({RR, CC, OO, OUTR, OUTC, OUTO}, target);

    void check(const Buffer<TYPE> &, const Buffer<TYPE> &, const Buffer<TYPE> &results);

    check(inx, inw, results);

    cout << "Success!\n";

    return 0;

}



void check(const Buffer<TYPE> &x, const Buffer<TYPE> &w, const Buffer<TYPE> &results) {

    Buffer<TYPE> golden(RR, CC, OO, OUTR, OUTC, OUTO);

    for (int outo = 0; outo < OUTO; outo++) {

        for (int outr = 0; outr < OUTR; outr++) {

            for (int outc = 0; outc < OUTC; outc++) {

                for (int oo = 0; oo < OO; oo++) {

                    for (int rr = 0; rr < RR; rr++) {

                        for (int cc = 0; cc < CC; cc++) {

                            golden(rr, cc, oo, outr, outc, outo) = 0;

                            for (int i = 0; i < OUTI * II; i++) {

                                for (int q = 0; q < Q; q++) {

                                    for (int p = 0; p < P; p++) {

                                        golden(rr, cc, oo, outr, outc, outo) +=

                                            (TYPE)x(outc * CC + cc + q, outr * RR + rr + p, i) * w(q, p, i, outo * OO + oo);

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

    check_equal_6D<TYPE>(golden, results);

}


