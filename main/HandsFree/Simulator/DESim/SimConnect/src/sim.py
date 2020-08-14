import subprocess
import _thread
from concurrent import futures
import time
import os

"""
    Global Variables
"""
proj_dir = "../top_module"  # path to project directory

"""
    signals to ModelSim testbench:
    's': switch
    'k': key
    'p': ps/2
    'start': simulation start
    'end': simulation end
    
    signals from ModelSim testbench:
    'frame': vga frame update
    'h': seven-seg (in hexadecimal)
    'l': LED (in binary)
    'p': ps/2 lock LED (in binary)
"""


def setProjectDir(path):
    global proj_dir
    proj_dir = path


def initVGA():
    global proj_dir
    file_name = os.path.join(proj_dir, "ModelSim/demo.txt")
    try:
        with open(file_name, "w") as file:
            for i in range(640 * 480):
                file.write('0')
    except FileNotFoundError:
        print("[project]/ModelSim not found, please check your project directory")
        exit(1)


# start button
def startSim():
    global proj_dir
    initVGA()

    print("start simulation ...")
    proc = subprocess.Popen(["vsim", "-c"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    try:
        proj_path = '/'.join(proj_dir.split('\\'))
        print(proj_path)
        command = "cd " + proj_path + "/ModelSim\n"
        proc.stdin.write(command.encode('utf-8'))
        proc.stdin.flush()
        proc.stdin.write(b"do testbench.tcl\n")
        proc.stdin.flush()
    except:
        print("fail to start simulation")
    return proc


# stop button
def stopSim(proc):
    if (proc):
        try:
            proc.stdin.write(b"end\n")
            proc.stdin.flush()
        except:
            pass
        print(proc.pid)
        proc.kill()
        print("end simulation")


def switchOn(proc, index):
    if proc and proc.poll() is None:
        print("switch on " + index)
        try:
            out_string = 'so' + index + '\n'
            proc.stdin.write(out_string.encode('utf-8'))
            proc.stdin.flush()
        except:
            print("simulation error")


def switchOff(proc, index):
    if proc and proc.poll() is None:
        print("switch off " + index)
        try:
            out_string = 'sf' + index + '\n'
            proc.stdin.write(out_string.encode('utf-8'))
            proc.stdin.flush()
        except:
            print("simulation error")


def keyPush(proc, index, turn):
    if proc and proc.poll() is None:
        print("key pressed " + index)
        try:
            out_string = 'k' + index + turn + '\n'
            proc.stdin.write(out_string.encode('utf-8'))
            proc.stdin.flush()
        except:
            print("simulation error")


def nextFrame(proc):
    if proc and proc.poll() is None:
        try:
            proc.stdin.write("next\n".encode('utf-8'))
            proc.stdin.flush()
        except:
            print("simulation error")


# code: make or break code
def keyboardPress(proc, code_buffer):
    if proc and proc.poll() is None:
        try:
            # "p": ps2 device
            val = "p" + code_buffer[0].strip() + '\n'
            code_buffer.pop(0)
            proc.stdin.write(val.encode('utf-8'))
            proc.stdin.flush()
        except:
            print("simulation error")


def getOutput(proc, data):
    # global thread_pool_executor

    while True:
        if proc and proc.poll() is None:
            # read ModelSim output
            line = proc.stdout.readline().decode('utf-8')

            # # skip simulation log
            # if line[0] == '#' or line[0] == '\r' or line.startswith("ModelSim") or line.startswith("Reading"):
            #     pass

            # 7-seg display, led, ps2 keyboard LED
            if line.startswith("h") or line.startswith("l") or line.startswith("p") or line.startswith("frame"):
                out_string = line.strip() + "\r\n"
                data.outb = out_string.encode('utf-8')
            # error messages
            elif line.startswith("# **"):
                out_string = line.strip() + "\r\n"
                data.outb = out_string.encode('utf-8')
