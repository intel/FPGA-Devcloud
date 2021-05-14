# PairHMM Tutorial

>  Xiaochen Hao, Intel & Peking University, xiaochen.hao@intel.com

Pairwise Hidden Markov Model (PairHMM) is an important part of the HaplotypeCaller of GATK 3.6 toolchain.

PairHMM aligns a string (a read) `R` with another string (a haplotype) `H`, which have the lengths of `m` and `n`, respectively. PairHMM calculates 3 matrices, `M`, `I` and `D`, according to the following equations (Source: Ren, S., Bertels, K., & Al-Ars, Z. (2018). Efficient Acceleration of the Pair-HMMs Forward Algorithm for GATK HaplotypeCaller on Graphics Processing Units. Evolutionary Bioinformatics, 14, 1-12. DOI:10.1177/1176934318760543):

Input:

```plaintext
integers: m, n
arrays:   R[m + 1], Q[m + 1], H[n + 1], alpha[m + 1], delta[m + 1], zeta[m + 1]
```

Initialization:

```plaintext
M(i, 0) = I(i, 0) = D(i, 0) = 0,  i in [0, m]
M(0, j) = I(0, j) = 0             j in [0, n]
D(0, j) = 1 / n                   j in [0, n]
```

Recurrence:

```plaintext
M(i, j) = lamda(i, j) * { alpha(i) * M(i - 1, j - 1) + beta(i) * I(i - 1, j - 1) + gamma(i) * D(i - 1, j - 1)}
I(i, j) = delta(i) * M(i - 1, j) + epsilon(i) * I(i - 1, j)
D(i, j) = zeta(i) * M(i, j - 1) + eta(i) * D(i, j - 1)
```

where

```plaintext
lamda(i, j) = 1 - Q(i) if R(i) == H(j), or Q(i) / 3 otherwise.
beta(i) = gamma(i) = 0.9
epsilon(i) = eta(i) = 0.1
```

Results:

```plaintext
Result = sum of M(m, j) + I(m, j) j in [1, n]
```

For implementing the PairHMM algorithm, the above equations are all we need, and we do not have to understand the biological background.

## How to design a systolic array?

![](tiling/figures/dataflow.gif)

If we let loop `i` and `j` be space loops, we get a 2-D array. Note that the dependence shown above implies a systolic array design. `M(i, j)` depends on the values stored at the left upper corner, while `I(i, j)` depends on the left and `D(i, j)` depends on the top. It is a relatively complex dependence pattern compared with the dense tensor kernel such as GEMM. Our framework can easily express it with the UREs and space-time transform.

## Design 1: Tiling

We assume a set of equal-length reads to be compared with a set of equal-length haps. A practical design must handle multiple `Haps` and `Reads` strings with a long length. Similar to other workloads, mapping large input data to a systolic array requires blocking the iteration space like this:

```plaintext
  for (h = 0; h < NUM_HAPS; h++)
    for (r = 0; r < NUM_READS; r++)
      for (oj = 0; oj < (n + 1) / JJ; oj++)
        for (oi = 0; oi < (m + 1) / II; oi++)
          for (jj = 0; jj < JJ; jj++)
            for (ii = 0; ii < II; ii++) 
```

For each tile, we can apply the same space-time scheduling as above.

![](tiling/figures/tiled.png)

Unlike workloads such as GEMM, the tiling of input strings brings inter-tile dependence, which must be explicitly specified in UREs. For example, the iteration at (i, j) = (2, 1) depends on the value from the last tile (1, 0) and (1, 1). Our framework can handle such cases automatically.

```
#define A                       ii,      jj,      rrr,  hhh,  oi,   oj,   rr,  hh
#define A_ii_minus_1            ii-1,    jj,      rrr,  hhh,  oi,   oj,   rr,  hh
#define A_jj_minus_1            ii,      jj-1,    rrr,  hhh,  oi,   oj,   rr,  hh
#define A_ii_minus_1_jj_minus_1 ii-1,    jj-1,    rrr,  hhh,  oi,   oj,   rr,  hh
#define A_last_ii               ii+II-1, jj,      rrr,  hhh,  oi-1, oj,   rr,  hh
#define A_last_ii_jj_minus_1    ii+II-1, jj-1,    rrr,  hhh,  oi-1, oj,   rr,  hh
#define A_last_jj               ii,      jj+JJ-1, rrr,  hhh,  oi,   oj-1, rr,  hh
#define A_ii_minus_1_last_jj    ii-1,    jj+JJ-1, rrr,  hhh,  oi,   oj-1, rr,  hh
#define A_last_ii_last_jj       ii+II-1, jj+JJ-1, rrr,  hhh,  oi-1, oj-1, rr,  hh

Hap(A)    = select(ii == 0, H(j, h), Hap(A_ii_minus_1));
Read(A)   = select(jj == 0, R(i, r), Read(A_jj_minus_1));
Quality(A)= select(jj == 0, Q(i, r), Quality(A_jj_minus_1));
Alpha(A)  = select(jj == 0, alpha(i, r), Alpha(A_jj_minus_1));
Delta(A)  = select(jj == 0, delta(i, r), Delta(A_jj_minus_1));
Zeta(A)   = select(jj == 0, zeta(i, r), Zeta(A_jj_minus_1));
Lamda(A)  = select(Read(A) == Hap(A), 1.0f - Quality(A), Quality(A) / 3);

#define M_expr(x)    Lamda(A) * (Alpha(A) * M(x) + beta * I(x) + gamma * D(x))
#define I_expr(x)    Delta(A) * M(x) + epsilon * I(x)
#define D_expr(x)    Zeta(A) * M(x) + eta * D(x)

M(A)  = select(i_is_0(A) || j_is_0(A), 0.0f,
            select(ii == 0, select(jj == 0, M_expr(A_last_ii_last_jj),
                                            M_expr(A_ii_minus_1_last_jj)),
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
```

Next compile the `tiling/main.cpp` file:

```
rm -rf ~/tmp/a*
cd /path/to/tutorials/tiling
g++ main.cpp -g -I ../util -I ../../../../Halide/include -L ../../../../Halide/bin -lHalide -lz -lpthread -ldl -std=c++11
env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 AOC_OPTION="-march=emulator" HL_DEBUG_CODEGEN=4 PRAGMAUNROLL=1 ./a.out >& b
```

Please remember to clean the generated file in the directory `~/tmp`, otherwise you may encounter some errors. The emulation should throw a "Success" message. Now compile it to RTL, then open the report:

```
cd ~/tmp
aoc -rtl a.cl
open ~/tmp/a/reports/report.html
switch to Throughput Analysis -> Fmax II
```

Oops! We expect all kernels can be scheduled to maximal frequency (240MHz for A10 and 480MHz for S10), and the Block II value is 1. However, the Block II of kernel `Result`is 24, which lowers the overall performance. We will figure out the reason and solve it in the next step.

![](tiling/figures/report.png)

## Design 2: Reorder

"The launch frequency of a new loop iteration is called the initiation interval (II). II refers to the number of hardware clock cycles for which the pipeline must wait before it can process the next loop iteration. An optimally unrolled loop has an II value of 1 because one loop iteration is processed every clock cycle." (Intel FPGA SDK for OpenCL Pro Edition: Best Practices Guide)

In short, the value computed at previous iterations will suddenly be used by the next iteration. The OpenCL compiler is hard to pipeline such a small dependence distance. A basic idea is to move the independent dimensions inward; we choose to tile the dimension `R, H` into `RR, HH` and `RRR, HHH` and move `RRR, HHH` inward, which extend the distance to RRR*HHH=40. Compile the `reorder/main.cpp` file and generate the static analysis report:

![](reorder/figures/report.png)

Great! The loop iterations are fully pipelined. Now we can synthesis the design:

```
source ~/t2s-os/setenv.sh devcloud run pac_s10
cd ~/tmp
aoc -v -fpc -fp-relaxed -profile -llc-arg=-set-dspba-feature=maxFilenamePrefixLength,integer,220 a.cl
```

Next profile the program with the following instructions:

```
env DISABLE_AUTORUN=1 BITSTREAM=a.aocx HL_DEBUG_CODEGEN=4 DELAYUNROLL=1 ./a.out >& b
aocl report a.aocx a.source profile.mon
```

![](reorder/figures/profile.png)

The design stalls on memory access and the occupancy ratio are low; that is to say, the systolic array runs slowly and wastes most of the time on fetching input data. We first try to speed up the systolic array since there is an obvious inefficiency in our UREs, then optimize memory access.

## Design 3: Preprocess

The previous design requires a high-cost floating divide operation in`Lamda`. To eliminate it, we can preprocess these operations at the host end and transfer the results to the device.  Rewrite the UREs as:

```
AlphaMatch(A) = select(jj == 0, alpha_match(i, r), AlphaMatch(A_jj_minus_1));
AlphaGap(A)   = select(jj == 0, alpha_gap(i, r), AlphaGap(A_jj_minus_1));
BetaMatch(A)  = select(jj == 0, beta_match(i, r), BetaMatch(A_jj_minus_1));
BetaGap(A)    = select(jj == 0, beta_gap(i, r), BetaGap(A_jj_minus_1));

Alpha(A) = select(Read(A) == Hap(A), AlphaMatch(A), AlphaGap(A));
Beta(A)  = select(Read(A) == Hap(A), BetaMatch(A), BetaGap(A));
```

How to calculate the `*Match, *Gap` is omitted. The generated hardware now only needs to select appropriate data according to the incoming strings. The preprocessing overhead is relatively small compared with the on-the-fly processing.

![](preprocess/figures/profile.png)

However, the results are not what we are expected. The execution time nearly doubled compared with the previous design due to a higher memory bandwidth pressure. We must pipeline the memory access and computing, that is, build a customized I/O network.

## Design 4: Build I/O Network

<img src="ionet/figures/ionet.png" style="zoom: 70%;" />

We need to build an I/O network to run in parallel with the PE array, as shown in the above figure, namely isolate access to buffers allocated in the device memory into separate kernels `hLoader, rLoader, unloader`.  Add the below code:

```
Hap.isolate_producer_chain(H, HSerializer, HLoader, HFeeder)
	.isolate_producer_chain({R, delta, zeta, eta, alpha_match, alpha_gap, beta_match, beta_gap}, RSerializer, RLoader, RFeeder);
Result.isolate_consumer_chain(Unloader, Deserializer);
```

It is a simple I/O network since the isolated kernels just perform memory access, not involving other operations. From the profiling results, we see that though the loader kernels stalls on writing data into its channels, the systolic array do not stall on reading data, indicating a pipelined execution.

![](ionet/figures/profile-code.png)

The occupancy ratio is still lower than what we expected (bigger is better). The systolic array runs too slow to catch up with the memory access. To boost it up, next, we scale up the current design to a bigger size, which would consume more data at once.

## Design 5: Scaling up

The previous design shows that only about 2% of DSPs are used, and almost 98% of on-chip resources remain idle. It is simple to adjust the systolic array size with the tiling factor, but it requires several trial-and-error attempts to determine the maximal size a specific board can realize. Let us scale up the previous design to the size 24x8.

We use `GCups` instead of `GFlops` to measure the performance since the update of `lamda` depends on the input sequences. The `GCups` is defined as:

```
(read length × haplotype length) ÷ PairHMM time
That is: (RRR * RR * OI * II * HHH * HH * OJ * JJ) ÷ PairHMM time
```

From the synthesis results, we can see the design consumes 24% DSP blocks and run at 349Mhz, a good result.

<img src="scaleup/figures/synthesis.png" style="zoom:70%;" />

Our kernel executes 69.51ms and achieved 46`GCups`. Not a bad result. The profiling results also shows a higher occupancy and bandwidth.

![](scaleup/figures/profile.png)



[TODO] Support random length of input sequences.