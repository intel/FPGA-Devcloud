# KnightRider7Segment

If you have not previously worked on the part 5 of the [Intro to Quartus](https://github.com/intel/FPGA-Devcloud/blob/master/main/HandsFree/Devkits/DE10-Lite/Example_Projects/Intro_to_Quartus/Intro_to_Quartus_Remote_Lab.pdf) lab, you can use this project as an example of how the program is supposed to run. Compared to the Intro to Quartus lab, you do not have to do any coding for this project. Once you download the project, compile to look at the LED sequence and the 7 segment display(s) count. 

![image](https://user-images.githubusercontent.com/67120855/91612037-89fafb00-e94a-11ea-9607-4ee09bfe1eef.png)

## KnightRider Background

Perhaps some of you have heard of or watched a TV show called Knight Rider that aired from 1982 to 1986 and starred David Hasselhoff.The premise of the show was David Hasselhoff was a high-tech crime fighter (at least high technology for 1982) and drove around an intelligent car named “KITT”. The KITT car was a 1982 Pontiac Trans-Am sports car with all sorts of cool gadgets. The interesting gadget of interest for this lab were the headlights of KITT which consisted of a horizontal bar of lights that sequence done at a time from left to right and back again at the rate of about 1/10th of a second per light. In this project you will see sequential logic and flip-flops. Let’s quickly review how flip-flops work. 

Flip-flops are basic storage elements in digital electronics. In their simplest form, they have 3 pins: D, Q, and Clock. The diagram of voltage versus time (often referred to as a waveform) for a flip-flop is shown below. Flip-flops capture the value of the “D” pin when the clock pin (the one with the triangle at its input transitions from low to high). This value of D then shows up at the Q output of the flip-flop a very short time later. The figure below is a flip-flop diagram.

![image](https://user-images.githubusercontent.com/67120855/91610798-ed375e00-e947-11ea-83af-13489c9aef21.png)

When you connect several flip-flops together serially you get what is known as a shift register. That circuit serves as the basis for the Knight Rider LED circuit that we will study in this lab. Note how we clock in a 1 for a single cycle and it “shifts” through the circuit. If that “1” is driving an LED each successive LED will light up for 1/10 of a second. The figure below is a shift register diagram.

![image](https://user-images.githubusercontent.com/67120855/91610972-3daebb80-e948-11ea-8b5d-fd8e71512da6.png)