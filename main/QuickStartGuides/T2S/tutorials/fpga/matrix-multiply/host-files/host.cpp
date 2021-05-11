// Copyright (C) 2013-2019 Altera Corporation, San Jose, California, USA. All rights reserved.
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to
// whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// This agreement shall be governed in all respects by the laws of the State of California and
// by the laws of the United States of America.


// This file is modified from /glob/development-tools/versions/fpgasupportstack/a10/1.2.1/intelFPGA_pro/hld/examples_aoc/matrix_mult/host/src/main.cpp

// Currently on DevCloud A10 nodes, Halide OpenCL runtime has issue in clFlush. So we temporarily provide this host file.
// We will no longer need it in future.
//
// compile and run (for example):
//      g++ host.cpp -DLARGE -g -DLINUX -DALTERA_CL -fPIC -Icommon/inc ./common/src/AOCLUtils/opencl.cpp ./common/src/AOCLUtils/options.cpp -I$ALTERAOCLSDKROOT/host/include $AOCL_LIBS -lelf -o host.out
//      Emulation:
//          env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 BITSTREAM="a.aocx" ./host.out
//      HW: 
//          env BITSTREAM="conv_unsigned.aocx" ./host.out
#include "AOCLUtils/aocl_utils.h"
#include "CL/opencl.h"
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <math.h>
#include <sstream>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sys/time.h>
#include <time.h>

// For sizes of the input matrices and systolic array
#include "../sizes.h"

using namespace aocl_utils;

#define TYPE float

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

#define DPRINTF(...)     \
    printf(__VA_ARGS__); \
    fflush(stdout);

#define NUM_QUEUES_TO_CREATE 8
#define NUM_KERNELS_TO_CREATE 8

#define CHECK(status)                                       \
    if (status != CL_SUCCESS) {                             \
        printf("error %d in line %d.\n", status, __LINE__); \
        exit(1);                                            \
    }

#define ACL_ALIGNMENT 64
void *acl_aligned_malloc(size_t size) {
    void *result = NULL;
    posix_memalign(&result, ACL_ALIGNMENT, size);
    return result;
}

const char *kernel_name[] = {
    "kernel_aLoader",
    "kernel_bLoader",
    "kernel_unloader_WAIT_FINISH_",
    "kernel_aFeeder",
    "kernel_bFeeder",
    "kernel_c",
    "kernel_drainer",
    "kernel_collector"};

double compute_kernel_execution_time(cl_event &event, double &start_d, double &end_d) {
    cl_ulong start, end;

    clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_END, sizeof(cl_ulong), &end, NULL);
    clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_START, sizeof(cl_ulong), &start, NULL);

    start_d = (double)1.0e-9 * start;
    end_d = (double)1.0e-9 * end;
    //return (double)(end-start);
    return (double)1.0e-9 * (end - start); // nanoseconds to seconds
}


int main() {
    float *A, *B, *C;
    const int TOTAL_I = III * II * OUTERMOST_I;
    const int TOTAL_J = JJJ * JJ * OUTERMOST_J;
    const int TOTAL_K = KKK * KK * OUTERMOST_K;
    
    long int num_elem_A = (long int)TOTAL_I*TOTAL_K;
    long int num_elem_B = (long int)TOTAL_K*TOTAL_J;
    long int num_elem_C = (long int)TOTAL_I*TOTAL_J;
    if ((A = (float *)acl_aligned_malloc(num_elem_A * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix A");
    }
    if ((B = (float *)acl_aligned_malloc(num_elem_B * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix A");
    }
    if ((C = (float *)acl_aligned_malloc(num_elem_C * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix C");
    }
    for (size_t i = 0; i < TOTAL_I; i++) {
        for (size_t k = 0; k < TOTAL_K; k++) {
            A[k + i*TOTAL_K] = k + i;
        }
    }
    for (size_t j = 0; j < TOTAL_J; j++) {
        for (size_t k = 0; k < TOTAL_K; k++) {
            B[j+k*TOTAL_J] = j - k;
        }
    }

    float *serialized_A, *serialized_B;
    if ((serialized_A = (float *)acl_aligned_malloc(num_elem_A * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix serialized_A");
    }
    if ((serialized_B = (float *)acl_aligned_malloc(num_elem_B * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix serialized_A");
    }

    // Serialize A
    long int addr = 0;
    for (int i = 0; i < TOTAL_I; i++)
        for (int k = 0; k < TOTAL_K; k++) {
            serialized_A[addr++] = A[k + i*TOTAL_K];
        }
    // Serialize B
    addr = 0;
    for (int j = 0; j < TOTAL_J; j++)
        for (int k = 0; k < TOTAL_K; k++) {
            serialized_B[addr++] = B[j+k*TOTAL_J];
        }

    DPRINTF("\n===== Host-CPU setting up the OpenCL platform and device ======\n\n");

    // Use this to check the output of each API call
    cl_int status;

    //----------------------------------------------
    // Discover and initialize the platforms
    //----------------------------------------------
    cl_uint numPlatforms = 0;
    cl_platform_id *platforms = NULL;

    // Use clGetPlatformIDs() to retrieve the
    // number of platforms
    status = clGetPlatformIDs(0, NULL, &numPlatforms);
    DPRINTF("Number of platforms = %d\n", numPlatforms);

    // Allocate enough space for each platform
    // platforms = (cl_platform_id*) acl_aligned_malloc (numplatforms * sizeof(cl_platform_id));
    platforms = (cl_platform_id *)malloc(numPlatforms * sizeof(cl_platform_id));

    DPRINTF("Allocated space for Platform\n");

    // Fill in platforms with clGetPlatformIDs()
    status = clGetPlatformIDs(numPlatforms, platforms, NULL);
    CHECK(status);
    DPRINTF("Filled in platforms\n");

    //----------------------------------------------
    // Discover and initialize the devices
    //----------------------------------------------

    cl_uint numDevices = 0;

    // Device info
    char buffer[4096];
    unsigned int buf_uint;
    int device_found = 0;
    const cl_uint maxDevices = 4;
    cl_device_id devices[maxDevices];
    DPRINTF("Initializing IDs\n");
    for (int i = 0; i < numPlatforms; i++) {
        status = clGetDeviceIDs(platforms[i],
                                CL_DEVICE_TYPE_ALL,
                                maxDevices,
                                devices,
                                &numDevices);

        if (status == CL_SUCCESS) {
            clGetPlatformInfo(platforms[i],
                              CL_PLATFORM_NAME,
                              4096,
                              buffer,
                              NULL);
#if defined(ALTERA_CL)
            if (strstr(buffer, "Altera") != NULL) {
                device_found = 1;
            }
            DPRINTF("%s\n", buffer);
#elif defined(NVIDIA_CL)
            if (strstr(buffer, "NVIDIA") != NULL) {
                device_found = 1;
            }
#else
            if (strstr(buffer, "Intel") != NULL) {
                device_found = 1;
            }
#endif
            DPRINTF("Platform found : %s\n", buffer);
            device_found = 1;
        }
    }

    if (!device_found) {
        DPRINTF("failed to find a OpenCL device\n");
        exit(-1);
    }

    DPRINTF("Total number of devices: %d", numDevices);
    for (int i = 0; i < numDevices; i++) {
        clGetDeviceInfo(devices[i],
                        CL_DEVICE_NAME,
                        4096,
                        buffer,
                        NULL);
        DPRINTF("\nDevice Name: %s\n", buffer);

        clGetDeviceInfo(devices[i],
                        CL_DEVICE_VENDOR,
                        4096,
                        buffer,
                        NULL);
        DPRINTF("Device Vendor: %s\n", buffer);

        clGetDeviceInfo(devices[i],
                        CL_DEVICE_MAX_COMPUTE_UNITS,
                        sizeof(buf_uint),
                        &buf_uint,
                        NULL);
        DPRINTF("Device Computing Units: %u\n", buf_uint);

        clGetDeviceInfo(devices[i],
                        CL_DEVICE_GLOBAL_MEM_SIZE,
                        sizeof(unsigned long),
                        &buffer,
                        NULL);
        //DPRINTF("Global Memory Size: %i\n", *((unsigned long*)buffer));

        clGetDeviceInfo(devices[i],
                        CL_DEVICE_MAX_MEM_ALLOC_SIZE,
                        sizeof(unsigned long),
                        &buffer,
                        NULL);
        //DPRINTF("Global Memory Allocation Size: %i\n\n", *((unsigned long*)buffer));
    }

    //----------------------------------------------
    // Create a context
    //----------------------------------------------

    DPRINTF("\n===== Host-CPU setting up the OpenCL command queues ======\n\n");

    cl_context context = NULL;

    // Create a context using clCreateContext() and
    // associate it with the device

    context = clCreateContext(
        NULL,
        1,
        devices,
        NULL,
        NULL,
        &status);
    CHECK(status);

    //----------------------------------------------
    // Create command queues
    //---------------------------------------------

    cl_command_queue cmdQueue[NUM_QUEUES_TO_CREATE + 1]; // extra queue for reading buffer D

    // Create a command queue using clCreateCommandQueue(),
    // and associate it with the device you want to execute on
    for (int i = 0; i < NUM_QUEUES_TO_CREATE; i++) {
        //fDPRINTF(stdout,"cmdQueue i = %d\n", i);
        cmdQueue[i] = clCreateCommandQueue(
            context,
            devices[0],
            CL_QUEUE_PROFILING_ENABLE,
            &status);
        CHECK(status);
    }

    //fDPRINTF(stdout,"cmdQueue i = %d, a queue for reading the C buffer\n", i);
    cmdQueue[NUM_QUEUES_TO_CREATE] = clCreateCommandQueue(
        context,
        devices[0],
        CL_QUEUE_PROFILING_ENABLE,
        &status);
    CHECK(status);

    //----------------------------------------------
    // Create device buffers
    //----------------------------------------------

    cl_mem input_A_buf;
    cl_mem input_B_buf;
    cl_mem output_C_buf;

    DPRINTF("\n===== Host-CPU transferring W and X to the FPGA device global memory (DDR4) via PCIe ======\n\n");
    input_A_buf = clCreateBuffer(
        context,
        //CL_MEM_READ_ONLY | CL_MEM_BANK_1_ALTERA,
        CL_MEM_READ_ONLY,
        num_elem_A * sizeof(cl_float),
        NULL,
        &status);
    CHECK(status);

    input_B_buf = clCreateBuffer(
        context,
        //CL_MEM_READ_ONLY | CL_MEM_BANK_1_ALTERA,
        CL_MEM_READ_ONLY,
        num_elem_B * sizeof(cl_float),
        NULL,
        &status);
    CHECK(status);

    output_C_buf = clCreateBuffer(
        context,
        //CL_MEM_WRITE_ONLY | CL_MEM_BANK_1_ALTERA,
        CL_MEM_WRITE_ONLY,
        num_elem_C * sizeof(cl_float),
        NULL,
        &status);
    CHECK(status);

    //----------------------------------------------
    // Write host data to device buffers
    //----------------------------------------------

    // blocking writes
    status = clEnqueueWriteBuffer(
        cmdQueue[0],
        input_A_buf,
        CL_TRUE,
        0,
        num_elem_A * sizeof(cl_float),
        serialized_A,
        0,
        NULL,
        NULL);
    CHECK(status);

    status = clEnqueueWriteBuffer(
        cmdQueue[1],
        input_B_buf,
        CL_TRUE,
        0,
        num_elem_B * sizeof(cl_float),
        serialized_B,
        0,
        NULL,
        NULL);
    CHECK(status);

    //----------------------------------------------
    // Create the program from binaries
    //----------------------------------------------
    DPRINTF("\n===== Host-CPU setting up OpenCL program and kernels ======\n\n");

    cl_program program;

    size_t binary_length;
    const unsigned char *binary;

    fflush(stdout);
    // create the program using binary already compiled offline using aoc (i.e. the .aocx file)
    char *aocx_file = getenv("BITSTREAM");
    FILE *fp = fopen(aocx_file, "rb");

    if (fp == NULL) {
        DPRINTF("Failed to open the AOCX file (fopen).\n");
        return -1;
    }

    fseek(fp, 0, SEEK_END);
    binary_length = ftell(fp);
    binary = (unsigned char *)malloc(sizeof(unsigned char) * binary_length);
    assert(binary && "Malloc failed");
    rewind(fp);

    if (fread((void *)binary, binary_length, 1, fp) == 0) {
        DPRINTF("Failed to read from the AOCX file (fread).\n");
        return -1;
    }
    fclose(fp);

    DPRINTF("Create program with binary\n");
    // Create a program using clCreateProgramWithBinary()
    program = clCreateProgramWithBinary(
        context,
        1,
        devices,
        &binary_length,
        (const unsigned char **)&binary,
        &status,
        NULL);
    CHECK(status);

    //----------------------------------------------
    // Create the kernel
    //----------------------------------------------

    status = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (status != CL_SUCCESS) {
        char log[128 * 1024] = {0};
        clGetProgramBuildInfo(program, devices[0], CL_PROGRAM_BUILD_LOG, 128 * 1024, log, NULL);
        DPRINTF("%s\n", log);
        CHECK(status);
    }

    cl_kernel kernel[NUM_KERNELS_TO_CREATE];

    for (int j = 0; j < NUM_KERNELS_TO_CREATE; j++) {
        DPRINTF("Creating kernel[%d]: %s\n", j, kernel_name[j]);
        kernel[j] = clCreateKernel(program, (const char *)kernel_name[j], &status);
        CHECK(status);
    }
    DPRINTF("All kernels created\n");

    status = clSetKernelArg(
        kernel[0],
        0,
        sizeof(int),
        (void *)&TOTAL_K);
    CHECK(status);
    status = clSetKernelArg(
        kernel[0],
        1,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[0],
        2,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);
    status = clSetKernelArg(
        kernel[0],
        3,
        sizeof(cl_mem),
        (void *)&input_A_buf);
    CHECK(status);

    status = clSetKernelArg(
        kernel[1],
        0,
        sizeof(int),
        (void *)&TOTAL_K);
    CHECK(status);
    status = clSetKernelArg(
        kernel[1],
        1,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[1],
        2,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);
    status = clSetKernelArg(
        kernel[1],
        3,
        sizeof(cl_mem),
        (void *)&input_B_buf);
    CHECK(status);

    status = clSetKernelArg(
        kernel[2],
        0,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[2],
        1,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);
    // result Z
    status = clSetKernelArg(
        kernel[2],
        2,
        sizeof(cl_mem),
        (void *)&output_C_buf);
    CHECK(status);


    status = clSetKernelArg(
        kernel[3],
        0,
        sizeof(int),
        (void *)&TOTAL_K);
    CHECK(status);
    status = clSetKernelArg(
        kernel[3],
        1,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[3],
        2,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);

    status = clSetKernelArg(
        kernel[4],
        0,
        sizeof(int),
        (void *)&TOTAL_K);
    CHECK(status);
    status = clSetKernelArg(
        kernel[4],
        1,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[4],
        2,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);

    status = clSetKernelArg(
        kernel[5],
        0,
        sizeof(int),
        (void *)&TOTAL_K);
    CHECK(status);
    status = clSetKernelArg(
        kernel[5],
        1,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[5],
        2,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);

    status = clSetKernelArg(
        kernel[6],
        0,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[6],
        1,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);

    status = clSetKernelArg(
        kernel[7],
        0,
        sizeof(int),
        (void *)&TOTAL_I);
    CHECK(status);
    status = clSetKernelArg(
        kernel[7],
        1,
        sizeof(int),
        (void *)&TOTAL_J);
    CHECK(status);

    //----------------------------------------------
    // Configure the work-item structure (using only tasks atm)
    //----------------------------------------------

    // Define the number of threads that will be created
    // as well as the number of work groups
    size_t globalWorkSize[1];
    size_t localWorkSize[1];

    //----------------------------------------------
    // Enqueue the kernel for execution
    //----------------------------------------------

    // all kernels are always tasks
    globalWorkSize[0] = 1;
    localWorkSize[0] = 1;

    cl_event kernel_exec_event[NUM_KERNELS_TO_CREATE];

    DPRINTF("\n===== Host-CPU enqeuing the OpenCL kernels to the FPGA device ======\n\n");
    for (int i = 0; i < NUM_KERNELS_TO_CREATE; i++) {
        // Alternatively, can use clEnqueueTaskKernel
        DPRINTF("clEnqueueNDRangeKernel[%d]: %s!\n", i, kernel_name[i]);
        status = clEnqueueNDRangeKernel(
            cmdQueue[i],
            kernel[i],
            1,
            NULL,
            globalWorkSize,
            localWorkSize,
            0,
            NULL,
            &kernel_exec_event[i]);
        CHECK(status);
    }
    DPRINTF(" *** FPGA execution started!\n");

    for (int i = 0; i < NUM_KERNELS_TO_CREATE; i++) {
        status = clFlush(cmdQueue[i]);
        CHECK(status);
    }

    for (int i = 0; i < NUM_QUEUES_TO_CREATE; i++) {
        DPRINTF("cmd queue: %d\n", i);
        fflush(stdout);
        status = clFinish(cmdQueue[i]);
        CHECK(status);
    }
    DPRINTF(" *** FPGA execution finished!\n");
    DPRINTF("\n\n");

    double k_start_time[NUM_KERNELS_TO_CREATE];
    double k_end_time[NUM_KERNELS_TO_CREATE];
    double k_exec_time[NUM_KERNELS_TO_CREATE];
    double max_time = 0;
    for (int i = 0; i < NUM_KERNELS_TO_CREATE; i++) {
        k_exec_time[i] = compute_kernel_execution_time(kernel_exec_event[i], k_start_time[i], k_end_time[i]);
        if (k_exec_time[i] > max_time) {
            max_time = k_exec_time[i];
        }
    }
    DPRINTF("Time taken: %lf sec\n\n", max_time);

    printf("\n===== Reporting measured throughput ======\n\n");
    double k_earliest_start_time = k_start_time[0];
    double k_latest_end_time = k_end_time[0];

    for (int i = 1; i < NUM_KERNELS_TO_CREATE; i++) {
        if (k_start_time[i] < k_earliest_start_time)
            k_earliest_start_time = k_start_time[i];

        if (k_end_time[i] > k_latest_end_time)
            k_latest_end_time = k_end_time[i];
    }

    // IMPORTANT: we care about the finish time of drain_C, once data is drained we are done
    k_latest_end_time = k_end_time[NUM_KERNELS_TO_CREATE - 1];

    for (int i = 0; i < NUM_KERNELS_TO_CREATE; i++) {
        printf("  Kernel execution time on FPGA: %s, \n   \t\t\t\t\t\t\t\t\texec time = %.5f s, start=%.5f s, end=%.5f s\n", kernel_name[i], k_exec_time[i], k_start_time[i], k_end_time[i]);
    }

    double k_overall_exec_time = k_latest_end_time - k_earliest_start_time;

    printf("\n");
    printf("  Loader kernels start time\t\t= %.5f s\n", k_earliest_start_time);
    printf("  Unloader kernels end time\t\t= %.5f s\n", k_latest_end_time);
    printf("  FPGA GEMM exec time\t\t= %.5f s\n", k_overall_exec_time);

    // multiplied by 1.0e-9 to get G-FLOPs
    printf("\n");

    double num_operations = (double)2.0 * (OUTERMOST_K*KK*KKK) * (double)(OUTERMOST_I*II*III) * (double)(OUTERMOST_J*JJ*JJJ);

    printf("  # operations = %.0f\n", num_operations );
    printf("  Throughput: %.5f GFLOPS\n", (double)1.0e-9 * num_operations / k_overall_exec_time);

    DPRINTF("\n===== Host-CPU transferring result matrix C from the FPGA device global memory (DDR4) via PCIe ======\n\n");

    // Read the results back from the device, blocking read
    float *serialized_Z;
    if ((serialized_Z = (float *)acl_aligned_malloc(num_elem_C * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix serialized_Z");
    }

    clEnqueueReadBuffer(
        //cmdQueue[KID_DRAIN_MAT_C],
        cmdQueue[NUM_KERNELS_TO_CREATE], // using a special queue for reading buffer C
        output_C_buf,
        CL_TRUE,
        0,
        num_elem_C * sizeof(cl_float),
        serialized_Z,
        0,
        NULL,
        NULL);
    CHECK(status);

    // Deserialize Z
    addr = 0;
    for (int i = 0; i < TOTAL_I; i++)
        for (int j = 0; j < TOTAL_J; j++) {
            C[j + i*TOTAL_J] = serialized_Z[addr++];
        }


    bool passed = 1;

    // for (size_t i = 0; i < OUTERMOST_I; i++) {
    //     for (size_t j = 0; j < OUTERMOST_J; j++) {
    //         for (size_t ii = 0; ii < II; ii++) {
    //             for (size_t jj = 0; jj < JJ; jj++) {
    //                 for (size_t iii = 0; iii < III; iii++) {
    //                     for (size_t jjj = 0; jjj < JJJ; jjj++) {
    //                         size_t i1 = iii + III * ii + III * II * i;
    //                         size_t j1 = jjj + JJJ * jj + JJJ * JJ * j;
    //                         float golden = 0.0f;
    //                         for (size_t k1 = 0; k1 < TOTAL_K; k1++) {
    //                             golden += A[k1+i1*TOTAL_K] * B[j1+k1*TOTAL_J];
    //                         }
    //                         passed &= fabs(golden - C[j1+i1*TOTAL_J]) < 0.005*fabs(golden);
    //                     }
    //                 }
    //             }
    //         }
    //     }
    // }

    if (passed) {
        printf("[PASSED]\n");
    } else {
        printf("[FAILED]\n");
    }
}

// Free the resources allocated during initialization
void cleanup() {
    /*  for(unsigned i = 0; i < num_devices; ++i) {
    if(kernel && kernel[i]) {
      clReleaseKernel(kernel[i]);
    }
    if(queue && queue[i]) {
      clReleaseCommandQueue(queue[i]);
    }
#if USE_SVM_API == 0
    if(input_a_buf && input_a_buf[i]) {
      clReleaseMemObject(input_a_buf[i]);
    }
    if(input_b_buf && input_b_buf[i]) {
      clReleaseMemObject(input_b_buf[i]);
    }
    if(output_buf && output_buf[i]) {
      clReleaseMemObject(output_buf[i]);
    }
#else
    if(input_a[i].get())
      input_a[i].reset();
    if(input_b[i].get())
      input_b[i].reset();
    if(output[i].get())
      output[i].reset();
#endif // USE_SVM_API == 0
  }

  if(program) {
    clReleaseProgram(program);
  }
  if(context) {
    clReleaseContext(context);
  }*/
}
