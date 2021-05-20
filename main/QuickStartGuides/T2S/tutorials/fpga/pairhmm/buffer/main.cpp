// To compile and run:
//    g++ PairHMM.cpp  -g -O0 -I ../util  -I ../../../../Halide/include -L ../../../../Halide/bin -lHalide -lpthread -ldl -std=c++11 -DEMU
//    rm ~/tmp/a.* ~/tmp/a -rf
//    env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 AOC_OPTION="-march=emulator" HL_DEBUG_CODEGEN=4 PRAGMAUNROLL=1 ./a.out &>b
//
// About the design:
//    See ../../../doc/workload_analysis/PairHMM.md for a description.

#include "util.h"

#ifdef EMU
#define RR          4
#define HH          4
#define OI          4
#define OJ          4
#define RRR         4
#define HHH         4
#define II          4
#define JJ          4
#else
#define RR          32
#define HH          32
#define OI          16
#define OJ          16
#define RRR         8
#define HHH         9
#define II          8
#define JJ          24
#endif

#define NUM_READS (RR * RRR)
#define NUM_HAPS  (HH * HHH)
#define MLEN (OI * II)
#define NLEN (OJ * JJ)

#define PLACE Place::Device

void check_correctness(ImageParam &H, ImageParam &R, ImageParam &delta, ImageParam &zeta, ImageParam &eta,
                       ImageParam &alpha_match, ImageParam &alpha_gap, ImageParam &beta_match, ImageParam &beta_gap,
                       const Buffer<float> &result);
void set_real_input(ImageParam &H, ImageParam &R, ImageParam &delta, ImageParam &zeta, ImageParam &eta,
                    ImageParam &alpha_match, ImageParam &alpha_gap, ImageParam &beta_match, ImageParam &beta_gap);
void set_pseudo_input(ImageParam &H, ImageParam &R, ImageParam &delta, ImageParam &zeta, ImageParam &eta,
                      ImageParam &alpha_match, ImageParam &alpha_gap, ImageParam &beta_match, ImageParam &beta_gap);

int main(void) {
    // Hap data
    ImageParam H(UInt(8), 2);

    // Read data
    ImageParam R(UInt(8), 2);
    ImageParam delta(Float(32), 2);
    ImageParam zeta(Float(32), 2);
    ImageParam eta(Float(32), 2);
    ImageParam alpha_match(Float(32), 2);
    ImageParam alpha_gap(Float(32), 2);
    ImageParam beta_match(Float(32), 2);
    ImageParam beta_gap(Float(32), 2);

    // Macros: for convenient use.
    #define A                       ii,      jj,      rrr,  hhh,  oi,   oj,   rr,  hh
    #define A_ii_minus_1            ii-1,    jj,      rrr,  hhh,  oi,   oj,   rr,  hh
    #define A_jj_minus_1            ii,      jj-1,    rrr,  hhh,  oi,   oj,   rr,  hh
    #define A_ii_minus_1_jj_minus_1 ii-1,    jj-1,    rrr,  hhh,  oi,   oj,   rr,  hh
    #define A_last_ii               ii+II-1, jj,      rrr,  hhh,  oi-1, oj,   rr,  hh
    #define A_last_ii_jj_minus_1    ii+II-1, jj-1,    rrr,  hhh,  oi-1, oj,   rr,  hh
    #define A_last_jj               ii,      jj+JJ-1, rrr,  hhh,  oi,   oj-1, rr,  hh
    #define A_ii_minus_1_last_jj    ii-1,    jj+JJ-1, rrr,  hhh,  oi,   oj-1, rr,  hh
    #define A_last_ii_last_jj       ii+II-1, jj+JJ-1, rrr,  hhh,  oi-1, oj-1, rr,  hh

    #define i                       (oi * II + ii)
    #define j                       (oj * JJ + jj)
    #define r                       (rr * RRR + rrr)
    #define h                       (hh * HHH + hhh)
    #define FLOAT_FUNC_DECL         Float(32), {A}, PLACE
    #define CHAR_FUNC_DECL          UInt(8), {A}, PLACE

    Var  A;
    Func Hap("Hap", CHAR_FUNC_DECL), Read("Read", CHAR_FUNC_DECL);
    Func Delta("Delta", FLOAT_FUNC_DECL), Zeta("Zeta", FLOAT_FUNC_DECL), Eta("Eta", FLOAT_FUNC_DECL);
    Func AlphaMatch("AlphaMatch", FLOAT_FUNC_DECL), AlphaGap("AlphaGap", FLOAT_FUNC_DECL);
    Func BetaMatch("BetaMatch", FLOAT_FUNC_DECL), BetaGap("BetaGap", FLOAT_FUNC_DECL);

    Hap(A)        = select(ii == 0, H(j, h), Hap(A_ii_minus_1));
    Read(A)       = select(jj == 0, R(i, r), Read(A_jj_minus_1));
    Delta(A)      = select(jj == 0, delta(i, r), Delta(A_jj_minus_1));
    Zeta(A)       = select(jj == 0, zeta(i, r), Zeta(A_jj_minus_1));
    Eta(A)        = select(jj == 0, eta(i, r), Eta(A_jj_minus_1));
    AlphaMatch(A) = select(jj == 0, alpha_match(i, r), AlphaMatch(A_jj_minus_1));
    AlphaGap(A)   = select(jj == 0, alpha_gap(i, r), AlphaGap(A_jj_minus_1));
    BetaMatch(A)  = select(jj == 0, beta_match(i, r), BetaMatch(A_jj_minus_1));
    BetaGap(A)    = select(jj == 0, beta_gap(i, r), BetaGap(A_jj_minus_1));

    #undef i
    #undef j
    #undef r
    #undef h

    Expr i_is_0 = (ii == 0 && oi == 0);
    Expr j_is_0 = (jj == 0 && oj == 0);
    Expr i_is_last = (ii == II - 1 && oi == OI - 1);
    Expr j_is_last = (jj == JJ - 1 && oj == OJ - 1);

    #define M_expr(x)    Alpha(A) * M(x) + Beta(A) * (I(x) + D(x))
    #define I_expr(x)    Delta(A) * M(x) + Eta(A) * I(x)
    #define D_expr(x)    Zeta(A)  * M(x) + Eta(A) * D(x)

    Func Alpha("Alpha", PLACE), Beta("Beta", PLACE), Result("Result", PLACE);
    Func M("M", FLOAT_FUNC_DECL), I("I", FLOAT_FUNC_DECL), D("D", FLOAT_FUNC_DECL), Sum("Sum", FLOAT_FUNC_DECL); 
    Alpha(A) = select(Read(A) == Hap(A), AlphaMatch(A), AlphaGap(A));
    Beta(A)  = select(Read(A) == Hap(A), BetaMatch(A), BetaGap(A));
    M(A)  = select(i_is_0 || j_is_0, 0.0f,
                select(ii == 0, select(jj == 0, M_expr(A_last_ii_last_jj),
                                                M_expr(A_last_ii_jj_minus_1)),
                                select(jj == 0, M_expr(A_ii_minus_1_last_jj),
                                                M_expr(A_ii_minus_1_jj_minus_1))));
    I(A)  = select(i_is_0 || j_is_0, 0.0f,
                select(ii == 0, I_expr(A_last_ii),
                                I_expr(A_ii_minus_1)));
    D(A)  = select(i_is_0, 1.0f / (NLEN - 1),
                select(j_is_0, 0.0f, 
                    select(jj == 0, D_expr(A_last_jj),
                                    D_expr(A_jj_minus_1))));
    Sum(A) = select(i_is_last,
                select(j_is_0, 0.0f,
                    select(jj == 0, Sum(A_last_jj), Sum(A_jj_minus_1))) + M(A) + I(A), 0.0f);
    Result(rrr, hhh, rr, hh) = select(i_is_last && j_is_last, Sum(A));

    Hap.merge_ures(Read, Delta, Zeta, Eta, AlphaMatch, AlphaGap, BetaMatch, BetaGap, Alpha, Beta, M, I, D, Sum, Result)
        .set_bounds(ii, 0, II, jj, 0, JJ)
        .set_bounds(rrr, 0, RRR, hhh, 0, HHH)
        .set_bounds(oi, 0, OI, oj, 0, OJ)
        .set_bounds(rr, 0, RR, hh, 0, HH)
        .space_time_transform(ii, jj);
    
    Func HSerializer("hSerializer", Place::Host), HLoader("hLoader", PLACE), HFeeder("hFeeder", PLACE);
    Func RSerializer("rSerializer", Place::Host), RLoader("rLoader", PLACE), RFeeder("rFeeder", PLACE);
    Func Unloader("unloader", PLACE), Deserializer("deserializer", Place::Host);

    Hap.isolate_producer_chain(H, HSerializer, HLoader, HFeeder)
       .isolate_producer_chain({R, delta, zeta, eta, alpha_match, alpha_gap, beta_match, beta_gap}, RSerializer, RLoader, RFeeder);
    Result.isolate_consumer_chain(Unloader, Deserializer).min_depth(64);
    Deserializer.output_buffer().set_bounds(RRR, HHH, RR, HH);

    RSerializer.remove(jj, hhh, oj, hh);
    RLoader.remove(jj, hhh, oj).min_depth(128);
    RFeeder.scatter(RLoader, ii).buffer(RLoader, rr).min_depth(64);
    HSerializer.remove(ii, rrr, oi, rr);
    HLoader.remove(ii, rrr, oi).min_depth(128);
    HFeeder.buffer(HLoader, rr).min_depth(64);

    Target target = get_host_target();
    target.set_feature(Target::IntelFPGA);
    target.set_feature(Target::Debug);
    set_pseudo_input(H, R, delta, zeta, eta, alpha_match, alpha_gap, beta_match, beta_gap);

    Buffer<float> result = Deserializer.realize({RRR, HHH, RR, HH}, target);
    check_correctness(H, R, delta, zeta, eta, alpha_match, alpha_gap, beta_match, beta_gap, result);
    cout << "Success!\n";
    return 0;
}

void set_pseudo_input(ImageParam &H, ImageParam &R, ImageParam &delta, ImageParam &zeta, ImageParam &eta,
                      ImageParam &alpha_match, ImageParam &alpha_gap, ImageParam &beta_match, ImageParam &beta_gap) {
#define beta_val          0.9f
#define eta_val           0.1f

    Buffer<unsigned char> inH = new_characters<NLEN, NUM_HAPS>(RANDOM);
    Buffer<unsigned char> inR = new_characters<MLEN, NUM_READS>(RANDOM);
    Buffer<float> inQ = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> in_alpha = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> in_delta = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> in_zeta = new_probability<float, MLEN, NUM_READS>(RANDOM);
    Buffer<float> in_eta(MLEN, NUM_READS);
    Buffer<float> in_alpha_match(MLEN, NUM_READS);
    Buffer<float> in_alpha_gap(MLEN, NUM_READS);
    Buffer<float> in_beta_match(MLEN, NUM_READS);
    Buffer<float> in_beta_gap(MLEN, NUM_READS);

    for (size_t i = 0; i < NUM_READS; i++) {
        for (size_t j = 0; j < MLEN; j++) {
            in_alpha_match(j, i) = (1.0f - inQ(j, i)) * in_alpha(j, i);
            in_alpha_gap(j, i) = (inQ(j, i) / 3) * in_alpha(j, i);
            in_beta_match(j, i) = (1.0f - inQ(j, i)) * beta_val;
            in_beta_gap(j, i) = (inQ(j, i) / 3) * beta_val;
            in_eta(j, i) = eta_val;
        }
    }
    H.set(inH);
    R.set(inR);
    delta.set(in_delta);
    zeta.set(in_zeta);
    eta.set(in_eta);
    alpha_match.set(in_alpha_match);
    alpha_gap.set(in_alpha_gap);
    beta_match.set(in_beta_match);
    beta_gap.set(in_beta_gap);
}

void check_correctness(ImageParam &H, ImageParam &R, ImageParam &delta, ImageParam &zeta, ImageParam &eta,
                       ImageParam &alpha_match, ImageParam &alpha_gap, ImageParam &beta_match, ImageParam &beta_gap,
                       const Buffer<float> &result) {
    Buffer<unsigned char> inH = H.get();
    Buffer<unsigned char> inR = R.get();
    Buffer<float> in_delta = delta.get();
    Buffer<float> in_zeta = zeta.get();
    Buffer<float> in_eta = eta.get();
    Buffer<float> in_alpha_match = alpha_match.get();
    Buffer<float> in_alpha_gap = alpha_gap.get();
    Buffer<float> in_beta_match = beta_match.get();
    Buffer<float> in_beta_gap = beta_gap.get();

    for (int hh = 0; hh < HH; hh++) {
        for (int rr = 0; rr < RR; rr++) {
            for(int hhh = 0;hhh < HHH; hhh++) {
                for(int rrr = 0; rrr < RRR; rrr++) {
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
                            }
                            if (i == 0) {
                                M(0, j) = 0.0;
                                I(0, j) = 0.0;
                                D(0, j) = 1.0 / (NLEN - 1);
                            }

                            if (j != 0 && i != 0) {
                                float alpha = (inR(i, r) == inH(j, h)) ? in_alpha_match(i, r) : in_alpha_gap(i, r);
                                float beta  = (inR(i, r) == inH(j, h)) ? in_beta_match(i, r) : in_beta_gap(i, r);
                                M(i, j) = alpha * M(i - 1, j - 1) +  beta * (I(i - 1, j - 1) + D(i - 1, j - 1));
                                I(i, j) = in_delta(i, r) * M(i - 1, j) + in_eta(i, r) * I(i - 1, j);
                                D(i, j) = in_zeta(i, r) * M(i, j - 1) + in_eta(i, r) * D(i, j - 1);
                            }

                            if (i == MLEN - 1 && j > 0) {
                                golden += M(MLEN-1, j) + I(MLEN-1, j);
                            }
                        }
                    }
                    // printf("h, r = %d, %d. golden = %f, result = %f\n", h, r, golden, result(rrr, hhh, rr, hh));
                    assert(abs(golden - result(rrr, hhh, rr, hh)) < 1e-6);
                }
            } 
        }
    }
}
