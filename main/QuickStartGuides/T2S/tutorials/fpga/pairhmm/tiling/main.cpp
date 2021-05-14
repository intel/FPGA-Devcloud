// To compile and run:
//    g++ PairHMM.cpp  -g -I ../util  -I ../../../../Halide/include -L ../../../../Halide/bin -lHalide -lpthread -ldl -std=c++11 -DVERBOSE_DEBUG -O0 -DTINY
//    rm ~/tmp/a.* ~/tmp/a -rf
//    env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 AOC_OPTION="-march=emulator -O0 -g " ./a.out
//
// About the design:
//    See ../../../doc/workload_analysis/PairHMM.md for a description.

#include "util.h"

#define RR        4
#define HH        4
#define OI        4
#define OJ        4
#define RRR       8
#define HHH       5
#define II        4
#define JJ        4

#define NUM_READS (RR * RRR)
#define NUM_HAPS  (HH * HHH)
#define MLEN (OI * II)
#define NLEN (OJ * JJ)

#define beta          0.9f
#define gamma         0.9f
#define epsilon       0.1f
#define eta           0.1f

#define PLACE Place::Device

void check_correctness(const Buffer<unsigned char> &inH, const Buffer<unsigned char> &inR, const Buffer<float> &inQ, const Buffer<float> &inAlpha,
                       const Buffer<float> &inDelta, const Buffer<float> &inZeta, const Buffer<float> &result);

int main(void) {
    // Hap data
    ImageParam H(UInt(8), 2);

    // Read data
    ImageParam R(UInt(8), 2);
    ImageParam Q(Float(32), 2);
    ImageParam alpha(Float(32), 2);
    ImageParam delta(Float(32), 2);
    ImageParam zeta(Float(32), 2);

    // Macros: for convenient use.
    #define A                       ii,      jj,      oi,   oj,   rrr,  hhh,  rr,  hh
    #define A_ii_minus_1            ii-1,    jj,      oi,   oj,   rrr,  hhh,  rr,  hh
    #define A_jj_minus_1            ii,      jj-1,    oi,   oj,   rrr,  hhh,  rr,  hh
    #define A_ii_minus_1_jj_minus_1 ii-1,    jj-1,    oi,   oj,   rrr,  hhh,  rr,  hh
    #define A_last_ii               ii+II-1, jj,      oi-1, oj,   rrr,  hhh,  rr,  hh
    #define A_last_ii_jj_minus_1    ii+II-1, jj-1,    oi-1, oj,   rrr,  hhh,  rr,  hh
    #define A_last_jj               ii,      jj+JJ-1, oi,   oj-1, rrr,  hhh,  rr,  hh
    #define A_ii_minus_1_last_jj    ii-1,    jj+JJ-1, oi,   oj-1, rrr,  hhh,  rr,  hh
    #define A_last_ii_last_jj       ii+II-1, jj+JJ-1, oi-1, oj-1, rrr,  hhh,  rr,  hh

    #define i                       (oi * II + ii)
    #define j                       (oj * JJ + jj)
    #define r                       (rr * RRR + rrr)
    #define h                       (hh * HHH + hhh)
    #define FLOAT_FUNC_DECL         Float(32), {A}, PLACE
    #define CHAR_FUNC_DECL          UInt(8), {A}, PLACE

    Var  A;
    Func Hap(CHAR_FUNC_DECL), Read(CHAR_FUNC_DECL), Quality(FLOAT_FUNC_DECL), Alpha(FLOAT_FUNC_DECL), Delta(FLOAT_FUNC_DECL), Zeta(FLOAT_FUNC_DECL),
         M(FLOAT_FUNC_DECL), I(FLOAT_FUNC_DECL), D(FLOAT_FUNC_DECL), Sum(FLOAT_FUNC_DECL),              // A recurrent Func needs declare return type, args, and place.
         Lamda(PLACE), i_is_0(PLACE), j_is_0(PLACE), i_is_last(PLACE), j_is_last(PLACE), Result(PLACE); // A non-recurrent Func needs declare only its place.

    Hap(A)    = select(ii == 0, H(j, h), Hap(A_ii_minus_1));
    Read(A)   = select(jj == 0, R(i, r), Read(A_jj_minus_1));
    Quality(A)= select(jj == 0, Q(i, r), Quality(A_jj_minus_1));
    Alpha(A)  = select(jj == 0, alpha(i, r), Alpha(A_jj_minus_1));
    Delta(A)  = select(jj == 0, delta(i, r), Delta(A_jj_minus_1));
    Zeta(A)   = select(jj == 0, zeta(i, r), Zeta(A_jj_minus_1));
    Lamda(A)  = select(Read(A) == Hap(A), 1.0f - Quality(A), Quality(A) / 3);

    i_is_0(A) = (ii == 0 && oi == 0);
    j_is_0(A) = (jj == 0 && oj == 0);
    i_is_last(A) = (ii == II - 1 && oi == OI - 1);
    j_is_last(A) = (jj == JJ - 1 && oj == OJ - 1);

    #define M_expr(x)    Lamda(A) * (Alpha(A) * M(x) + beta * I(x) + gamma * D(x))
    #define I_expr(x)    Delta(A) * M(x) + epsilon * I(x)
    #define D_expr(x)    Zeta(A) * M(x) + eta * D(x)

    M(A)  = select(i_is_0(A) || j_is_0(A), 0.0f,
                select(ii == 0, select(jj == 0, M_expr(A_last_ii_last_jj),
                                                M_expr(A_last_ii_jj_minus_1)),
                                select(jj == 0, M_expr(A_ii_minus_1_last_jj),
                                                M_expr(A_ii_minus_1_jj_minus_1))));
    I(A)  = select(i_is_0(A) || j_is_0(A), 0.0f,
                select(ii == 0, I_expr(A_last_ii),
                                I_expr(A_ii_minus_1)));
    D(A)  = select(i_is_0(A), 1.0f / (NLEN - 1),
                select(j_is_0(A), 0.0f, 
                    select(jj == 0, D_expr(A_last_jj),
                                    D_expr(A_jj_minus_1))));
    Sum(A) = select(i == MLEN-1,
                select(j_is_0(A), 0.0f,
                    select(jj == 0, Sum(A_last_jj), Sum(A_jj_minus_1))) + M(A) + I(A), 0.0f);
    Result(rrr, hhh, rr, hh) = select(i_is_last(A) && j_is_last(A), Sum(A));

    #undef i
    #undef j
    #undef r
    #undef h

    Hap.merge_ures(Read, Quality, Alpha, Delta, Zeta, Lamda, i_is_0, j_is_0, M, I, D, Sum, Result)
        .set_bounds(ii, 0, II, jj, 0, JJ)
        .set_bounds(rrr, 0, RRR, hhh, 0, HHH)
        .set_bounds(oi, 0, OI, oj, 0, OJ)
        .set_bounds(rr, 0, RR, hh, 0, HH)
        .space_time_transform(ii, jj);

    // Generate input.
    Buffer<unsigned char> inH = new_characters<NLEN, NUM_HAPS>(RANDOM);
    Buffer<unsigned char> inR = new_characters<MLEN, NUM_READS>(RANDOM);
    Buffer<float> inQ         = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> inAlpha     = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> inDelta     = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> inZeta      = new_probability<float, MLEN, NUM_READS>(RANDOM);

    H.set(inH);
    R.set(inR);
    Q.set(inQ);
    alpha.set(inAlpha);
    delta.set(inDelta);
    zeta.set(inZeta);

    Target target = get_host_target();
    target.set_feature(Target::IntelFPGA);
    target.set_feature(Target::Debug);

    Buffer<float> result = Result.realize({RRR, HHH, RR, HH}, target);
    check_correctness(inH, inR, inQ, inAlpha, inDelta, inZeta, result);
    cout << "Success!\n";
    return 0;
}

void check_correctness(const Buffer<unsigned char> &inH, const Buffer<unsigned char> &inR, const Buffer<float> &inQ, const Buffer<float> &inAlpha,
                       const Buffer<float> &inDelta, const Buffer<float> &inZeta, const Buffer<float> &result) {
    for (int hh = 0; hh < HH; hh++) {
        for (int rr = 0; rr < RR; rr++) {
            for(int hhh = 0;hhh < HHH;++hhh){
                for(int rrr = 0; rrr < RRR; ++rrr){
                    int r = rr * RRR + rrr;
                    int h = hh * HHH + hhh;
                    float golden = 0.0;
                    Buffer<float> M(MLEN, NLEN);
                    Buffer<float> I(MLEN, NLEN);
                    Buffer<float> D(MLEN, NLEN);
                    for (int j = 0; j < NLEN; j++) {
                        for (int i = 0; i < MLEN; i++) {
                            if (j == 0) {
                                M(i, 0) = 0.0;
                                I(i, 0) = 0.0;
                                D(i, 0) = 0.0;
                            }j
                            if (i == 0) {
                                M(0, j) = 0.0;
                                I(0, j) = 0.0;
                                D(0, j) = 1.0 / (NLEN - 1);
                            }

                            if (j != 0 && i != 0) {
                                float lamda = (inR(i, r) == inH(j, h)) ? 1 - inQ(i, r) : inQ(i, r) / 3;
                                M(i, j) = lamda * (inAlpha(i, r) * M(i - 1, j - 1) + beta * I(i - 1, j - 1) + gamma * D(i - 1, j - 1));
                                I(i, j) = inDelta(i, r) * M(i - 1, j) + epsilon * I(i - 1, j);
                                D(i, j) = inZeta(i, r) * M(i, j - 1) + eta * D(i, j - 1);
                            }

                            if (i == MLEN - 1 && j > 0) {
                                golden += M(MLEN-1, j) + I(MLEN-1, j);
                            }
                        }
                    }
                    printf("h, r = %d, %d. golden = %f, result = %f\n", h, r, golden, result(rrr,hhh,rr,hh));
                    assert(abs(golden - result(rrr, hhh, rr, hh)) < 1e-6);
                }
            } 
        }
    }
}
