import sys
import socket
import selectors
import types
import asyncio
import subprocess
import re
import time
import threading
from concurrent import futures
import _thread
import os

from sim import *

"""
    Global Variables
"""
sel = selectors.DefaultSelector()

proc = None        # simulation process
keyboard_buf = []        # list to store keyboard inputs


def start_connections(host, port):
    server_addr = (host, port)

    connid = 1
    print("starting connection", connid, "to", server_addr)
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setblocking(False)
    sock.connect_ex(server_addr)
    events = selectors.EVENT_READ | selectors.EVENT_WRITE
    data = types.SimpleNamespace(
        connid=connid,
        recv_total=0,
        outb=b"",
    )
    sel.register(sock, events, data=data)


def service_connection(key, mask):
    sock = key.fileobj

    if mask & selectors.EVENT_READ:
        recv_data = sock.recv(1024)  # Should be ready to read

        if recv_data:
            # print("received", repr(recv_data), "from connection", key.data.connid)
            commands = recv_data.decode('utf-8').split("\r\n")
            for command in commands:
                if command != '':
                    parse_command(command, key.data)
        # connection broken
        if not recv_data:
            print("closing connection", key.data.connid)
            sel.unregister(sock)
            sock.close()

    if mask & selectors.EVENT_WRITE:
        if key.data.outb:
            # print("sending", repr(key.data.outb), "to connection", key.data.connid)
            sent = sock.send(key.data.outb)  # Should be ready to write
            key.data.outb = key.data.outb[sent:]


def parse_command(command, data):
    global proc

    arguments = command.strip().split()

    if arguments[0] == "start":
        proc = startSim()
        _thread.start_new_thread(getOutput, (proc, data,))

    # SW index on/off
    elif arguments[0] == 'SW':
        if arguments[2] == '0':
            switchOff(proc, arguments[1])
        else:
            switchOn(proc, arguments[1])
    # KEY index on/off
    elif arguments[0] == 'KEY':
        keyPush(proc, arguments[1], arguments[2])

    elif arguments[0] == 'next':
        nextFrame(proc)

    # KB ScanCode
    elif arguments[0] == 'KB':
        keyboard_buf.append(arguments[1])
        keyboardPress(proc, keyboard_buf)

    elif arguments[0] == 'end':
        stopSim(proc)

    # set project path
    elif arguments[0] == 'PATH':
        setProjectDir(arguments[1])


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("usage:", sys.argv[0], "<port>")
        sys.exit(1)

    host = '127.0.0.1'
    port = sys.argv[1]
    start_connections(host, int(port))

    try:
        while True:
            events = sel.select(timeout=1)
            if events:
                for key, mask in events:
                    service_connection(key, mask)
            # Check for a socket being monitored to continue.
            if not sel.get_map():
                break
    except KeyboardInterrupt:
        print("caught keyboard interrupt, exiting")
    finally:
        sel.close()
        # TODO: make sure all subprocesses are killed
        stopSim(proc)

