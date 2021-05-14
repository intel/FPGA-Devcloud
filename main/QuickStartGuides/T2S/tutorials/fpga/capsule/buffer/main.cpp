#include "Halide.h"
#include "util.h"
using namespace Halide;

#ifdef EMU
#define B       4
#else
#define B	64
#endif

#define CO      32
#define H       7
#define W       7
#define MH      4
#define MW      4
#define R_KH    3
#define R_KW    3
#define R_MK    4
#define R_CI    32
#define POS_H   (H*2+R_KH-2)
#define POS_W   (W*2+R_KW-2)

#define R_CII   16
#define COI     1
#define BI      4
#define R_CIO   (R_CI/R_CII)
#define COO     (CO/COI)
#define BO      (B/BI)

#define P_pose      r_mk,  mh, r_cio*R_CII+r_cii, w*2+r_kw, h*2+r_kh, bo*BI+bi
#define LAYOUT_P    R_MK,  MH,              R_CI,    POS_W,    POS_H,        B

#define P_weight    coimw%MW,  r_mk, coo*COI+coimw/MW, r_cio*R_CII+r_cii,  r_kw,  r_kh
#define LAYOUT_W    MW,        R_MK,               CO,              R_CI,  R_KW,  R_KH

#define P_pose_all  r_cii,                  bi,         w,  r_cio,         r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define W_pose_all  r_cii,         coimw,         coo,      r_cio,         r_mk,        r_kw,        r_kh

#define P_order     r_cii,         coimw,   bi,   coo,  w,  r_cio,         r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define P           r_cii,         coimw,   bi,   coo,  w,  r_cio,         r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define P_coimw     r_cii,         coimw-1, bi,   coo,  w,  r_cio,         r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define P_bi        r_cii,         coimw,   bi-1, coo,  w,  r_cio,         r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define P_cii       r_cii-1,       coimw,   bi,   coo,  w,  r_cio,         r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define P_cio       r_cii+R_CII-1, coimw,   bi,   coo,  w,  r_cio-1,       r_mk,        r_kw,        r_kh,   mh,  h,  bo
#define P_mk        r_cii+R_CII-1, coimw,   bi,   coo,  w,  r_cio+R_CIO-1, r_mk-1,      r_kw,        r_kh,   mh,  h,  bo
#define P_kw        r_cii+R_CII-1, coimw,   bi,   coo,  w,  r_cio+R_CIO-1, r_mk+R_MK-1, r_kw-1,      r_kh,   mh,  h,  bo
#define P_kh        r_cii+R_CII-1, coimw,   bi,   coo,  w,  r_cio+R_CIO-1, r_mk+R_MK-1, r_kw+R_KW-1, r_kh-1, mh,  h,  bo
#define P_Out                      coimw,   bi,   coo,  w,                                                   mh,  h,  bo
#define LAYOUT_O                   COI*MW,  BI,   COO,  W,                                                   MH,  H,  BO

void validate_results(const Buffer<float> &pose, const Buffer<float> &weight, Buffer<float> &result)
{
    for (int b = 0; b < B; b++)
        for (int h = 0; h < H; h++)
            for (int w = 0; w < W; w++)
                for (int co = 0; co < CO; co++)
                    for (int mh = 0; mh < MH; mh++)
                        for (int mw = 0; mw < MW; mw++) {
                            float golden = 0.0f;
                            for (int r_ci = 0; r_ci < R_CI; r_ci++)
                                for (int r_kh = 0; r_kh < R_KH; r_kh++)
                                    for (int r_kw = 0; r_kw < R_KW; r_kw++)
                                        for (int r_mk = 0; r_mk < R_MK; r_mk++)
                                            golden += pose(r_mk, mh, r_ci, w*2+r_kw, h*2+r_kh, b)
                                                    * weight(mw, r_mk, co, r_ci, r_kw, r_kh);
                            int coimw = (co % COI) *MW +mw;
                            int coo = co / COI;
                            int bi = b % BI;
                            int bo = b / BI;
                            _halide_user_assert(result(P_Out) == golden) 
                                << "(" << coimw << ", " << bi  << ", " << w  << ", " << h << ", "
                                       << mh    << ", " << coo << ", " << bo << ") = "
                                << golden << ", not " << result(P_Out) << "\n";
                        }
}


int main(void)
{
    ImageParam pose(type_of<float>(), 6);
    ImageParam weight(type_of<float>(), 6);

    Var P;
    Func Pose(Float(32), { P }, Place::Device);
    Func Weight(Float(32), { P }, Place::Device);
    Func Vote(Float(32), { P }, Place::Device);
    Func Out(Place::Device);

    Expr cii_eq_0 = r_cii==0;
    Expr cio_eq_0 = r_cio==0;
    Expr mk_eq_0  = r_mk==0;
    Expr kw_eq_0  = r_kw==0;
    Expr first    = r_cii==0       && r_cio==0       && r_mk==0      && r_kw==0      && r_kh==0;
    Expr last     = r_cii==R_CII-1 && r_cio==R_CIO-1 && r_mk==R_MK-1 && r_kw==R_KW-1 && r_kh==R_KH-1;
    Pose(P)       = select(coimw == 0, pose(P_pose), Pose(P_coimw));
    Weight(P)     = select(bi == 0, weight(P_weight), Weight(P_bi));
    Vote(P)       = select(first, 0,
                        select(cii_eq_0,
                            select(cio_eq_0,
                                select(mk_eq_0,
                                    select(kw_eq_0, Vote(P_kh), Vote(P_kw)),
                                    Vote(P_mk)),
                                Vote(P_cio)),
                            Vote(P_cii))
                    ) + Pose(P) * Weight(P);
    Out(P_Out) = select(last, Vote(P));

    Pose.merge_ures(Weight, Vote, Out)
        .set_bounds(coimw, 0, COI*MW, coo,   0, COO,  mh,   0, MH)
        .set_bounds(r_mk,  0, R_MK,   r_kw,  0, R_KW, r_kh, 0, R_KH)
        .set_bounds(r_cio, 0, R_CIO,  r_cii, 0, R_CII)
        .set_bounds(w,     0, W,      h,     0, H)
        .set_bounds(bi,    0, BI,     bo,    0, BO)
        .space_time_transform(r_cii, coimw, bi)
        .vectorize(r_cii);

    Func pSerializer(Place::Host), wSerializer(Place::Host), outDeserializer(Place::Host);
    Func pLoader(Place::Device), pFeeder(Place::Device), wLoader(Place::Device), wFeeder(Place::Device);
    Func drainer(Place::Device), collector(Place::Device), unloader(Place::Device);

    Pose.isolate_producer_chain(pose, pSerializer, pLoader, pFeeder);
    pSerializer.remove(coimw, coo);
    pLoader.remove(coimw, coo).min_depth(1024);
    pFeeder.buffer(pLoader, r_cio, BufferStrategy::Double);
    pFeeder.scatter(pLoader, bi).min_depth(128);

    Pose.isolate_producer_chain(weight, wSerializer, wLoader, wFeeder);
    wSerializer.remove(bi, w, mh, h, bo);
    wLoader.remove(bi, w).min_depth(512);
    wFeeder.buffer(wLoader, r_cio, BufferStrategy::Double);
    wFeeder.scatter(wLoader, coimw).min_depth(128);

    Out.isolate_consumer(drainer).min_depth(128);
    drainer.space_time_transform(coimw, bi);
    drainer.isolate_consumer_chain(collector, unloader, outDeserializer);
    drainer.gather(Out, bi).min_depth(128);
    collector.gather(drainer, coimw);
    collector.vectorize(coimw).min_depth(128);
    unloader.vectorize(coimw);

    pose.set(new_data_6D<float, LAYOUT_P>(CONSTANT));
    weight.set(new_data_6D<float, LAYOUT_W>(CONSTANT));
    pose.set_bounds(LAYOUT_P);
    weight.set_bounds(LAYOUT_W);
    Out.output_buffer().set_bounds(LAYOUT_O);

    Target target = get_host_target();
    target.set_feature(Target::IntelFPGA);
    Buffer<float> result = outDeserializer.realize({ LAYOUT_O }, target);

    validate_results(pose.get(), weight.get(), result);
    cout << "Success!\n";
    return 0;
}
