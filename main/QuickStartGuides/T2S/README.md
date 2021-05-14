# Using T2S on FPGA DevCloud

T2S enables software programmers to build systolic arrays on Intel FPGAs for both productivity and performance. A binary of the tool, together with a set of tutorials, is freely available on Intel FPGA DevCloud. DevCloud provides a well-maintained software and hardware environment, making it really convenient for programmers.  

## Create a DevCloud account

 + Register at [DevCloud](https://software.intel.com/content/www/us/en/develop/tools/devcloud/fpga.html). In "Which software tools do you intend to use with your project?", please check "Other", and indicate "T2S" in the describe box. 
 + Follow the instructions of an approval email to set up your connection to DevCloud.

## Log in

+ log into a compute node:

    ```
    devcloud_login
    ```

+ Choose

    ```
    6) Enter Specific Node Number
       Choose a node with Arria 10 Release 1.2.1, or with Stratix 10.
    ```

##  Use tutorials

+ Create a directory and set up environment there:

  ```
  mkdir tutorials # Any other name is fine
  cd tutorials
  source /data/t2s/setenv.sh a10  # s10 if you chose a node with Stratix 10.
  ```

  When running any command in a tutorial, all generated files (e.g. OpenCL files, bitstreams) will be put under this directory. Note that these files are temporary, and might be overwritten as new commands run.

+ Play with a tutorial.

  + [Tutorial 1: Matrix multiply](tutorials/fpga/matrix-multiply/README.md)
  + [Tutorial 2: Capsule kernel](tutorials/fpga/capsule/README.md)
  + [Tutorial 3: PairHMM](tutorials/fpga/pairhmm/README.md)
  + [Tutorial 4: LU decomposition](tutorials/fpga/lu/README.md)
  + [Tutorial 5: Convolution](tutorials/fpga/2d-convolution/README.md)
  
  
  Usually, each tutorial starts from a simplest design, and evolves into a more sophisticated design step by step, every step addressing a visible performance bottleneck. Some tutorials might have been tried on A10 or S10 but not both.
  

## Contact us

We would love to hear your feedback. Please feel free to contact us: Hongbo Rong (hongbo.rong@intel.com), Mingzhe Zhang (zhangmz1210@mail.ustc.edu.cn), and Xiaochen Hao (xiaochen.hao@intel.com).