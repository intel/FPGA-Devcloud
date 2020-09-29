## 1 Introduction (v0.1)
DESim is a virtual FPGA interface that runs on top of ModelSim simulator. It allows a designer to run a simulation of a Verilog/VHDL digital design and display the results on a console representing an FPGA development kit. This step can be used in lieu of programming actual hardware or in addition to programming FPGA hardware.

## 2 Installation
### 2.1 Software requirements
1. Install the Mentor ModelSim simulator. You can get a free copy of Modelsim when you install the Intel FPGA Quartus Prime Lite software. The download link is here: https://fpgasoftware.intel.com/19.1/?edition=lite&platform=windows) . Note go to individual files and you can download Modelsim separately. No libraries are needed. The simulator will simulate RTL - if references to underlying FPGA primitives, these libraries will need to be manually referenced.
2. Install Java OpenJDK 11 or later (https://adoptopenjdk.net/?variant=openjdk11&jvmVariant=hotspot). Java is used to run the underlying application.
3. Install the Java GUI library package OpenJFX 11 or later (https://gluonhq.com/products/javafx/). You can install wherever you please, but take note of the installation path. No environment variable setting is needed for this, however you will be required to edit a path in the run batch script.

### 2.2 Setup on Windows
1. If you haven't done so download the installation zip file from this location: https://github.com/intel/FPGA-Devcloud/tree/master/main/HandsFree/Simulator/DESim
2. Extract the zip file.
3. Open `Simulator_jar/DESim_run.bat` with a simulator and change the path for `java --module-path` to `"[path-to-openJFX-sdk]\lib"` . Note that because the statement is in double quotes you don't need to escape the spaces in the path.
4. Startup a DOS command console (cmd). Change directory to the <install_location>/SimConsoleFPGA/DESim:  Run `DESim_run.bat` to start the DESim GUI interface .
5. Make sure that `vsim -c` (ModelSim command-line version) runs successfully in a Windows cmd console
6. In a second command console, Run `<install_location>/demo/led_demo/sim/demo.bat` to connect the interface to ModelSim simulator.

### 2.3 Setup on Linux
Coming soon.

## 3 Running Projects on the DESim console
### 3.1 Run sample projects
1. The demo directory directory contains a number of projects. Change directory to the demo of interest and launch demo.bat . You can interact with the console GUI by viewing LEDs, seven segments, VGA output and changing the values of switches and LEDs. The simulator will initialize the reg values to logic zero upon startup.
2. Run `DESim_run.bat` to start DESim interface.
3. Run `demo/led_demo/sim/demo.bat` to connect the interface to ModelSim and start simulation.
4. Click the checkboxes for switches and observe the LED lights changing.
5. Click `Stop` button in the tool bar to stop the simulation.

 

### 3.2 Create a new project
1. Using File Explorer, or other suitable means within Windows, make a copy of the `led_demo` folder, including the `sim` subfolder.
2. Under your new folder, open `hello.v` and add new modules in it. Other project files can be added in the same folder as `hello.v` Note that all files will be compiled in that folder so if you have two modules with the same name in your project, the latest one compiled will be referenced. You can adjust what gets compiled by modifying the`sim/demo.bat` vlog commands.
3. Save `hello.v` and associated submodules, and you can now run your project.  

Note: Please set the default nettype of all project files to none. (i.e. add "`default_nettype none" to all project files)

## 4 Testbench Considerations

### 4.1 Modify time precision of simulation
Time precision is set to `1ns/1ns` in `tb.v` and `hello.v`. You may modify the time precision and time scale based on your need.

### 4.2 Relation of simulation speed to actual hardware

Simulators take considerably more real time to produce results than actual FPGA hardware. The default clock in the testbench is 50 MHz . If you need a divided clock to trigger at 1 Hz you would divide the 50 MHz clock by 50,000,000. However, the simulator takes considerably longer to run and is roughly takes 4000x as long so you need to consider that 50 Mhz clock triggers 50 million times per second on FPGA hardware would only trigger 12,000 times per second on the simulator. Consider clock divide ratios carefully so your simulation will run in a reasonable amount of time.



