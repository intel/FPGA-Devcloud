## 1 Introduction (v0.1)
DESim is a virtual FPGA interface that runs on top of ModelSim simulator. It allows a designer to run a simulation of a schematic or Verilog/VHDL digital design and display the results on a console representing an FPGA development kit. This step can be used in lieu of programming actual hardware or in addition to programming FPGA hardware.

## 2 Installation
### 2.1 Software requirements
1. ModelSim (Intel FPGA starter edition 10.5b, available at https://fpgasoftware.intel.com/19.1/?edition=lite&platform=windows) . Note go to individual files and you can download Modelsim separately. No libraries are needed.
2. OpenJDK 11 or later (https://jdk.java.net/archive/) You can install anywhere, however you will need to setup your system variables to access. Go to your windows search bar and search for environment variables. Click on the app to edit the system properties. Left click environment variables. Under System variables, set JAVA_HOME to the full Windows path to jdk-14.0.1 . For the Path variable, set the path to <your_path>/bin for the jdk-14.0.1 installation.
3. OpenJFX 11 or later (https://gluonhq.com/products/javafx/) . No environment variable setting is needed for this, however you will be required to edit a path in the run batch script.

### 2.2 Setup on Windows
1. Download DESim, install OpenJDK and OpenJFX
2. Open `Simulator_jar/DESim_run.bat`, modify the arguments for `java --module-path` to `"[path-to-openJFX-sdk]\lib"`
3. Run `DESim_run.bat` to start the DESim GUI interface 
4. Make sure that `vsim -c` (ModelSim command-line version) runs successfully in a Windows cmd console
5. Run `demo/led_demo/sim/demo.bat` to connect the interface to ModelSim simulator.

### 2.3 Setup on Linux
Coming soon.

## 3 Running Projects on the DESim console
### 3.1 Run a sample project
1. Run `DESim_run.bat` to start DESim interface.
2. Run `demo/led_demo/sim/demo.bat` to connect the interface to ModelSim and start simulation.
3. Click the checkboxes for switches and observe the LED lights changing.
4. Click `Stop` button in the tool bar to stop the simulation.

 

### 3.2 Create a new project in Verilog
1. Using File Explorer, or other suitable means within Windows, make a copy of the `led_demo` folder, including the `sim` subfolder.
2. Under your new folder, open `hello.v` and add new modules in it. Other project files can be added in the same folder as `hello.v` Note that all files will be compiled in that folder so if you have two modules with the same name in your project, the latest one compiled will be referenced. You can adjust what gets compiled by modifying the`sim/demo.bat` vlog commands.
3. Save `hello.v` and associated submodules, and you can now run your project.  

Note: Please set the default nettype of all project files to none. (i.e. add "`default_nettype none" to all project files)

4. Keep in mind that the state of signals and registers are unknown using the simulator. If you dont get the results you are expecting, consider adding an initial block in your RTL block to set registers to a known reset state, or add a reset signal.

### 3.2 Create a new project using schematics

1. To create schematics, you will need to download the Quartus Prime Lite development tools. You can get the tools from this link: https://fpgasoftware.intel.com/19.1/?edition=lite&platform=windows . Login with credentials or create an account as requested.

2. Select Quartus Prime Lite development tools and the MAX10 library files and download. Generally the files will end up in your Downloads folder. The files are large, it might take up to 30 minutes to download.

3. Double click on the file QuartusLiteSetup-19.1.0.625-windows.exe (the version numbers might differ) and run through the install process. 

4. At this point, if you don't know the Quartus schematic tools, we suggest you try out this tutorial: https://ftp.intel.com/Public/Pub/fpgaup/pub/Teaching_Materials/current/Tutorials/Schematic/Quartus_II_Introduction.pdf . Create a project. Then go to File -> New - Block Diagram / Schematic File. Follow the steps in the tutorial and create a schematic. You need to name the signals exactly as they are named in of the demo/<any>_demo/tb/tb.v port list. For instance lets see you want to build a 2 input AND gate controlled by switches and output displayed on a single LED. name the 2 inputs SW[1] and SW[0] and output LED[0]. Save your schematic file. It is called a .bdf file.

5. In Quartus, File -> Create/Update -> Create HDL Design from Current File. Select Verilog. Hit Generate and you will get a resulting file such as AND2_schematic.v. You need to copy this file into the demo working folder (eg schematic_demo). 

6. Edit the top.v file and properly instantiate the AND2_schematic module into the main module. For this 2 input AND gate example, we can assign inputs A and B to SW[1] and SW[0], and when the switches change have the corresponding LEDs change as well. Then we can use LED[2] to display the output of the gate. The following code snippet inserted into top.v will work:

   	assign LED[1:0] = SW[1:0];
   	 AND2_schematic i_AND2_schematic (
   	.A(SW[0]),
   	.B(SW[1]),
   	.Z(LED[2]));

7. Launch DESim_run.bat as described in the previous section followed by demo.bat . 

### 3.3 Using Quartus Prime IP catalog blocks

Quartus Prime contains a large set of parameterized IP blocks. Should you include these (for instance a counter), you will need to make sure the simulator resolves these blocks. The demo.bat script contains library references to many commonly used IP blocks. When Modelsim launches it can resolve most IP blocks from this line in the demo.bat file:

vsim -pli simfpga.vpi -c -t 1ps -Lf altera_ver -Lf altera_mf_ver -Lf 220model_ver -Lf sgate_ver -Lf altera_lnsim_ver -Lf cyclonev -c -do "run -all" tb

The -Lf option will search in these libraries and resolve references. Should Modelsim fail to run properly and to an error free completion, you will need to look at the IP generated source and figure out what libraries need to be referenced to satisfy linking in Modelsim.

## 4 Testbench Considerations

### 4.1 Modify time precision of simulation
Time precision is set to `1ns/1ns` in `tb.v` and `hello.v`. You may modify the time precision and time scale based on your need.

### 4.2 Relation of simulation speed to actual hardware

Simulators take considerably more real time to produce results than actual FPGA hardware. The default clock in the testbench is 50 MHz . If you need a divided clock to trigger at 1 Hz you would divide the 50 MHz clock by 50,000,000. However, the simulator takes considerably longer to run and is roughly takes 4000x as long so you need to consider that 50 Mhz clock triggers 50 million times per second on FPGA hardware would only trigger 12,000 times per second on the simulator. Consider clock divide ratios carefully so your simulation will run in a reasonable amount of time.



