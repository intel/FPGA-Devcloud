## 1 Introduction (v0.1)
DESim is a virtual FPGA interface that runs on top of ModelSim simulator. It allows a designer to run a simulation of a Verilog/VHDL digital design and display the results on a console representing an FPGA development kit. This step can be used in lieu of programming actual hardware or in addition to programming FPGA hardware.

## 2 Installation
### 2.1 Software requirements
1. ModelSim (Intel FPGA starter edition 10.5b, available at https://fpgasoftware.intel.com/19.1/?edition=lite&platform=windows) . Note go to individual files and you can download Modelsim separately. No libraries are needed.
2. Python 3.6+ for Windows: https://www.python.org/downloads/
3. OpenJDK 11 or later (https://jdk.java.net/archive/) You can install anywhere, however you will need to setup your system variables to access. Go to your windows search bar and search for environment variables. Click on the app to edit the system properties. Left click environment variables. Under System variables, set JAVA_HOME to the full Windows path to jdk-14.0.1 . For the Path variable, set the path to <your_path>/bin for the jdk-14.0.1 installation.
4. OpenJFX 11 or later (https://gluonhq.com/products/javafx/) . No environment variable setting is needed for this, however you will be required to edit a path in the run batch script.

### 2.2 Setup on Windows
1. Download DESim, install OpenJDK and OpenJFX, install Python for Windows
2. Open `Simulator_jar/DESim_run.bat`, modify the arguments for `java --module-path` to `"[path-to-openJFX-sdk]\lib"`
3. Make sure that `vsim -c` (ModelSim command-line version) runs successfully in a Windows cmd console
4. Run `DESim_run.bat` to start the DESim GUI interface 
5. Run `SimConnect/src/client.py` by running `python client.py 54321` in the Windows cmd console to connect the interface to ModelSim simulator. Note that DESim_run.bat will occupy the command window, so open up a separate window for this Python step.

### 2.3 Setup on Linux
Coming soon.

## 3 Running Projects on the DESim console
### 3.1 Run a sample project
1. Run `DESim_run.bat` to start DESim interface.
2. Run `python client.py 54321` to connect the interface to ModelSim.
3. In the DESim interface, open `File->Open Project` and select `led_demo` folder.
4. Click `Run` button in the tool bar to start compiling and simulating the sample project.
5. Click the checkboxes for switches and observe the LED lights changing.
6. Click `Stop` button in the tool bar to stop the simulation.

 

### 3.2 Create a new project
1. Using File Explorer, or other suitable means within Windows, make a copy of the `top_module` folder, including the `ModelSim` subfolder.
2. Under your new folder, open `top.v` and add new modules at the `Program Modules` section. Other project files can be added in the same folder as `top.v` Note that all files will be compiled in that folder so if you have two modules with the same name in your project, the latest one compiled will be referenced. You can adjust what gets compiled by modifying the Modelsim/testbench.tcl vlog commands.
3. Save `top.v` and associated submodules, and you can now run your project.  

Note: Please do not change the name of `top.v` and the `ModelSim` subfolder.

4. Keep in mind that the state of signals and registers are unknown using the simulator. If you dont get the results you are expecting, consider adding an initial block in your RTL block to set registers to a known reset state, or add a reset signal.





## 4 Testbench Considerations
### 4.1 Add / Remove testbench modules
There are two modules `ps2_interface` and `vga_interface` in `top_module/ModelSim/testbench.v` to simulate PS/2 keyboard and VGA respectively. You may remove the modules and the corresponding signals.

### 4.2 Compile Altera libraries
The simulation command `vsim work.testbench` is included in `top_module/ModelSim/testbench.tcl`, additional arguments can be added to compile Altera libraries. (e.g. If `altsyncram` module is included in project design, the vsim command can be changed to `vsim -L altera_mf_ver -L altera_mf work.testbench`)

### 4.3 Modify time precision of simulation
Time precision is set to `10ns/10ns` in `top_module/ModelSim/testbench.v` for faster simulation. You may modify the time precision and time scale based on your need.

### 4.4 Relation of simulation speed to actual hardware

Simulators take considerably more real time to produce results than actual FPGA hardware. The default clock in the testbench is 50 MHz . If you need a divided clock to trigger at 1 Hz you would divide the 50 MHz clock by 50,000,000. However, the simulator takes considerably longer to run and is roughly takes 4000x as long so you need to consider that 50 Mhz clock triggers 50 million times per second on FPGA hardware would only trigger 12,000 times per second on the simulator. Consider clock divide ratios carefully so your simulation will run in a reasonable amount of time.




