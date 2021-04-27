## 1 Introduction (v0.1)
DESim is a virtual FPGA interface that runs on top of ModelSim simulator. It allows a designer to run a simulation of a Verilog/VHDL digital design and display the results on a console representing an FPGA development kit. This step can be used in lieu of programming actual hardware or in addition to programming FPGA hardware.

Note for access to an open source release of DESim please visit: https://github.com/fpgacademy/DESim .

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

 

### 3.2 Create a new project
1. Using File Explorer, or other suitable means within Windows, make a copy of the `led_demo` folder, including the `sim` subfolder.
2. Under your new folder, open `hello.v` and add new modules in it. Other project files can be added in the same folder as `hello.v` Note that all files will be compiled in that folder so if you have two modules with the same name in your project, the latest one compiled will be referenced. You can adjust what gets compiled by modifying the`sim/demo.bat` vlog commands.
3. Save `hello.v` and associated submodules, and you can now run your project.  

Note: Please set the default nettype of all project files to none. (i.e. add "`default_nettype none" to all project files)

4. Keep in mind that the state of signals and registers are unknown using the simulator. If you dont get the results you are expecting, consider adding an initial block in your RTL block to set registers to a known reset state, or add a reset signal.





## 4 Testbench Considerations

### 4.1 Modify time precision of simulation
Time precision is set to `1ns/1ns` in `tb.v` and `hello.v`. You may modify the time precision and time scale based on your need.

### 4.2 Relation of simulation speed to actual hardware

Simulators take considerably more real time to produce results than actual FPGA hardware. The default clock in the testbench is 50 MHz . If you need a divided clock to trigger at 1 Hz you would divide the 50 MHz clock by 50,000,000. However, the simulator takes considerably longer to run and is roughly takes 4000x as long so you need to consider that 50 Mhz clock triggers 50 million times per second on FPGA hardware would only trigger 12,000 times per second on the simulator. Consider clock divide ratios carefully so your simulation will run in a reasonable amount of time.



