# Digital Logic Trainer: Remote Console Edition

The purpose of the Digital Trainer project is to test the student’s knowledge of logic gates through a series of quizzes on logic gates ran on an FPGA development board. An FPGA is a type of computer chip that can be programmed to implement a variety of applications. Normally, this project is pre-programmed on a board, the student is able to powers up the board with the USB cable and try out a series of quizzes on how well they know Digital Logic. Without a board, the quizzes can still be run with the Remote Console board.

In order to do the Remote Console edition of the lab, Quartus should have previously be installed. If not yet installed, you can download Quartus [here](https://fpgasoftware.intel.com/20.1/?edition=lite&platform=windows). 

## 1. Remote Console Usage

Download and unarchive the LogicSolverHandsFree.qar file. Compile your program and launch the Remote Console GUI. Follow the picture below for instructions to operate.

**<u>Note:</u>** If you have already unarchived and need to rerun, go to the LogicSolverHandsFree_restored folder > quartus > double click RemoteLab.qpf and recompile.

![image](https://user-images.githubusercontent.com/67120855/89055049-66c73680-d31f-11ea-8f4b-aeba3b605b74.png)

​          

## **2. Using the Digital Trainer**

There are 10 challenges programmed into the board. It is your job to decide what the logic function of each challenge is (the challenge number is displayed on the right of the display) by flipping the input switches and observing the output LED (the light on the left of the board). A switch that is flipped “up” is a 1, and a switch flipped “down” is a 0. Likewise, an LED on is while an LED off is a 0. The number on the left indicates whether the function is two input (2In, thus using only the two rightmost switches, or 3In, using the three rightmost switches). You can flip between the different challenges using the buttons on the board: to advance to the next challenge press the rightmost button, or press the button to the left to advance to the previous challenge. Try to circle the correct function for each sequence!        

| Sequence Number | Number of Inputs |           Logic Function            |
| :-------------: | :--------------: | :---------------------------------: |
|        1        |        2         | AND     OR     NAND     NOR     XOR |
|        2        |        2         | AND     OR     NAND     NOR     XOR |
|        3        |        2         | AND     OR     NAND     NOR     XOR |
|        4        |        2         | AND     OR     NAND     NOR     XOR |
|        5        |        2         | AND     OR     NAND     NOR     XOR |
|        6        |        3         | AND     OR     NAND     NOR     XOR |
|        7        |        3         | AND     OR     NAND     NOR     XOR |
|        8        |        3         | AND     OR     NAND     NOR     XOR |
|        9        |        3         | AND     OR     NAND     NOR     XOR |
|       10        |        3         | AND     OR     NAND     NOR     XOR |

​To get the table above in excel format, click on LogicSolverChoice.xlsh at the top of this page.
