// The only header file needed for including T2S.

#include "Halide.h"



// For printing output

#include <stdio.h>



// For validation of results.

#include <assert.h>



#include "../util.h"



using namespace Halide;

using namespace std;



#define OUTO    2

#define OUTC    2

#define OUTR    2

#define OUTI    2

#define OO      8

#define CC      16

#define RR      8

#define Q       3

#define P       3

#define II      8



#define TYPE int

#define HALIDE_TYPE Int(32)



#define cc (cc_adjusted - Q + 1)

#define PLACE Place::Device



int main(void) {

    ImageParam x(type_of<TYPE>(), 3);

    ImageParam w(type_of<TYPE>(), 4);



// Macros: for convenient use.

// Note that we have to put loop rr outside of loop cc. Otherwise, the dependence vector due to A_last_q_previous_rr will be negative.

#define A                       ii,          p,     q,         cc_adjusted,         rr,     oo, outi,     outc, outr, outo

#define A_q_minus_1_cc_minus_1  ii,          p,     q - 1,     cc_adjusted - 1,     rr,     oo, outi,     outc, outr, outo

#define A_cc_minus_1            ii,          p,     q,         cc_adjusted - 1,     rr,     oo, outi,     outc, outr, outo

#define A_q_minus_1             ii,          p,     q - 1,     cc_adjusted,         rr,     oo, outi,     outc, outr, outo

#define A_p_minus_1             ii,          p - 1, q,         cc_adjusted,         rr,     oo, outi,     outc, outr, outo

#define A_outi_minus_1          ii + II - 1, p,     q,         cc_adjusted,         rr,     oo, outi - 1, outc, outr, outo

#define A_ii_minus_1            ii - 1,      p,     q,         cc_adjusted,         rr,     oo, outi,     outc, outr, outo

#define A_last_q_previous_rr    ii,          p + 1, q + Q - 1, cc_adjusted + Q - 1, rr - 1, oo, outi,     outc, outr, outo // Used only when q == 0. We must write as q+Q-1 \

                                                                                                                           // instead of Q-1 to help the compiler calculate the dependence

#define FUNC_DECL HALIDE_TYPE, {A}, PLACE



    Var A, rr1, t;

    Func X(FUNC_DECL), W(FUNC_DECL), H(FUNC_DECL), V(FUNC_DECL), Z(FUNC_DECL), // A recurrent Func needs declare return type, args, and place.

         z(PLACE);                                                              // A non-recurrent Func needs declare only its place.



    Expr x_for_first_q_last_p = x(outc * CC + cc + Q - 1, outr * RR + rr + P - 1, outi * II + ii);

    Expr x_for_first_q_other_p_first_rr = x(outc * CC + cc + Q - 1, outr * RR + p, outi * II + ii);



    X(A) = select(q == 0, select(p == P - 1, select(cc < CC, x_for_first_q_last_p, 0 /*arbitrary value, not contributing to output anyway*/), select(rr == 0, x_for_first_q_other_p_first_rr, X(A_last_q_previous_rr))),

                  select(cc >= q - (Q - 1), X(A_q_minus_1_cc_minus_1), 0 /*arbitrary value, not contributing to output anyway*/));

    W(A) = select(q == 0, select(cc <= 0, w(cc + Q - 1, p, outi * II + ii, outo * OO + oo), W(A_cc_minus_1)),

                  select(cc <= 0, select(cc >= q - (Q - 1), W(A_q_minus_1_cc_minus_1), 0 /*arbitrary value, not contributing to output anyway*/),

                         W(A_cc_minus_1)));

    H(A) = select(q == 0, 0, H(A_q_minus_1)) + X(A) * W(A);

    V(A) = select(q == Q - 1, select(p == 0, 0, V(A_p_minus_1)) + H(A), 0 /* arbitrary value, not contributing to output anyway*/);

    Z(A) = select(q == Q - 1 && p == P - 1, select(ii == 0 && outi == 0, 0, select(ii == 0, Z(A_outi_minus_1), Z(A_ii_minus_1))) + V(A), 0 /* arbitrary value, not contributing to output anyway*/);

    z(cc_adjusted, rr, oo, outc, outr, outo) = select(cc >= 0 && cc < CC && q == Q - 1 && p == P - 1 && ii == II - 1 && outi == OUTI - 1, Z(A));



    X.merge_ures(W, H, V, Z, z) // Put all the UREs into the same loop nest

     .set_bounds(ii, 0, II, p, 0, P, q, 0, Q)

     .set_bounds(cc_adjusted, 0, CC + 2 * Q - 2, rr, 0, RR, oo, 0, OO)

     .set_bounds(outi, 0, OUTI, outc, 0, OUTC, outr, 0, OUTR, outo, 0, OUTO);



    Func XSerializer1(Place::Host), XLoader1(PLACE), XFeeder1(PLACE), // For the few streams corresponding x_for_first_q_other_p_first_rr

         XSerializer2(Place::Host), XLoader2(PLACE), XFeeder2(PLACE),  // For most of the streams that correspond to x_for_first_q_last_p

         WSerializer(Place::Host), WLoader(PLACE), WFeeder1(PLACE), WFeeder2(PLACE),

         zCollector(PLACE), zUnloader(PLACE), zDeserializer(Place::Host);



    X.isolate_producer_chain(x_for_first_q_other_p_first_rr, XFeeder1)

     .isolate_producer_chain(x_for_first_q_last_p, XFeeder2)

     .isolate_producer_chain(w, WFeeder2);



    z.isolate_consumer_chain(zCollector);



    // For the output path, use the original domain for the cc loop (although still called cc_adjusted)

    zCollector.set_bounds(cc_adjusted, 0, CC)

        .set_bounds(rr, 0, RR, oo, 0, OO)

        .set_bounds(outc, 0, OUTC, outr, 0, OUTR, outo, 0, OUTO);



    // Generate input and run.

    Buffer<TYPE> inx = new_data_3D<TYPE, OUTC * CC + Q - 1, OUTR * RR + P - 1, OUTI * II>(SEQUENTIAL); //or RANDOM

    Buffer<TYPE> inw = new_data_4D<TYPE, Q, P, OUTI * II, OUTO * OO>(SEQUENTIAL);                      //or RANDOM

    x.set(inx);

    w.set(inw);

    Target target = get_host_target();

    target.set_feature(Target::IntelFPGA);

    target.set_feature(Target::Debug);

    Buffer<TYPE> results = zCollector.realize({CC, RR, OO, OUTC, OUTR, OUTO}, target);

    void check(const Buffer<TYPE> &, const Buffer<TYPE> &, const Buffer<TYPE> &results);

    check(inx, inw, results);

    cout << "Success!\n";

    return 0;

}



void check(const Buffer<TYPE> &x, const Buffer<TYPE> &w, const Buffer<TYPE> &results) {

    Buffer<TYPE> golden(CC, RR, OO, OUTC, OUTR, OUTO);

    for (int outo = 0; outo < OUTO; outo++) {

        for (int outr = 0; outr < OUTR; outr++) {

            for (int outc = 0; outc < OUTC; outc++) {

                for (int oo = 0; oo < OO; oo++) {

                    for (int rr = 0; rr < RR; rr++) {

                        for (int cc1 = 0; cc1 < CC; cc1++) {

                            golden(cc1, rr, oo, outc, outr, outo) = 0;

                            for (int i = 0; i < OUTI * II; i++) {

                                for (int q = 0; q < Q; q++) {

                                    for (int p = 0; p < P; p++) {

                                        golden(cc1, rr, oo, outc, outr, outo) +=

                                            (TYPE)x(outc * CC + cc1 + Q - 1 - q, outr * RR + rr + p, i) * w(Q - 1 - q, p, i, outo * OO + oo);

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


