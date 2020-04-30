

# Arria 10 PAC: OpenAPI (dpc++) Compilation and Programming on the FPGA devcloud using OneAPI version beta05

 

## 1       Introduction

If you are new to the Arria 10 PAC card with OpenCL, check out this quick start guide:

https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ug/ug-qs-ias-opencl-a10.pdf

For OneAPI documentation on FPGAs, please refer to:

https://software.intel.com/en-us/oneapi-fpga-optimization-guide-quick-reference

This demonstration will step the user through the following steps:

1. Select appropriate compute node machine on the FPGA devcloud
2. Load the appropriate tools
3. Copy over the sample dpc++ design
4. Take the sample design and compile for emulation mode (kernels will run on the CPU)
6. Execute in emulation mode
7. Convert the dpc++ code to RTL and into an FPGA executable 
8. Download the OpenCL FPGA bitstream to the PAC card
9. Run the application software on the host and show that the host CPU  and FPGA interact to solve heterogenous workloads. Results should be comparable to emulation mode, with improved throughput.



## 2       Assumptions

This lab assumes the following:

- Basic FPGA knowledge
- Basic dpc++ knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up, X2Go optional



## 3       Walkthrough

#### 3.1            Initial Setup

Run the devcloud_login function and connect to an OneAPI Arria 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

![image](https://user-images.githubusercontent.com/22804500/78613373-8d1d0f80-7820-11ea-80a0-6cc3194ded2d.png)

Select option 2 or option 5 and connect to an Arria 10 ready OneAPI node.

Once on this node, run tools_setup. Select the Arria 10 OneAPI option.

Make  working directory:

```bash
mkdir A10_ONEAPI
```

We will use a utility called oneapi-cli to copy over the sample design.

```
oneapi-cli
```

Select option (1) Create a project.

Selection (1) cpp

Scroll down to CPU, GPU, FPGA and select Vector Add

Create the sample sign under the A10_ONEAPI directory that you created in the prior step and exit the oneapi-cli utility.

#### 3.2 Running dpc++ vector-add project in the emulation mode

```
cd A10_ONEAPI/vector-add
```

In this directory, examine the Makefile.fpga file. It contains targets for run_emu which runs emulation mode, and run_hw.

```
make run_emu -f Makefile.fpga
```

You will observe the two commands that are run for emulation mode:

dpcpp  -fintelfpga src/vector-add.cpp -o vector-add.fpga_emu -DFPGA_EMULATOR
./vector-add.fpga_emu

Observe for the success message upon completion.

#### 3. 3 Running dpc++ vector-add project in FPGA hardware mode

In this step you will run the same Makefile.fpga file but now with the run_hw target.

```
make run_hw -f Makefile.fpga
```

Observe the messages below. Note how the OpenCL compiler is launched as a processing step to generate the FPGA executable hardware. This step takes approximately one hour.

dpcpp  -fintelfpga -c src/vector-add.cpp -o a.o -DFPGA
dpcpp  -fintelfpga a.o -o vector-add.fpga -Xshardware

aoc: Compiling for FPGA. This process may take several hours to complete.  Prior to performing this compile, be sure to check the reports to ensure the design will meet your performance targets.  If the reports indicate performance targets are not being met, code edits may be required.  Please refer to the oneAPI FPGA Optimization Guide for information on performance tuning applications for FPGAs.



Look for the success message upon completion.

./vector-add.fpga
Device: pac_a10 : Intel PAC Platform (pac_ee00000)
success

#### 4 	Batch Submission

The follow commands can be included in a batch script (in this case A10_oneapi_batch.sh) to launch the OneAPI emulation flow, followed by the compilation and FPGA board programming flow using make commands. Adjust commands to your own needs.

```
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10OAPI
make run_emu -f Makefile.fpga
make run_hw -f Makefile.fpga
```

From the headnode login-2, run this command:

```
devcloud_login -b A10OAPI A10_oneapi_batch.sh
```

To see the resulting terminal output, consult the files:

A10_oneapi_batch.sh.exxxxxx
A10_oneapi_batch.sh.oxxxxxx

xxxxxxx is a unique job ID. The .exxxxxx file is the error log and the .oxxxxxx file is the terminal log where success or failure of the commands can be determined.

#### 5       Document Revision History

List the revision history for the application note.

| Name         | Date      | Changes            |
| ------------ | --------- | ------------------ |
| Larry Landis | 4/5/2020  | Initial Release    |
| Larry Landis | 4/29/2020 | Batch Command flow |



 
