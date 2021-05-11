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

using namespace aocl_utils;

#define TYPE float

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)

#define DPRINTF(...)     \
    printf(__VA_ARGS__); \
    fflush(stdout);

#define NUM_QUEUES_TO_CREATE 5
#define NUM_KERNELS_TO_CREATE 5

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
    "kernel_loader_s0_run_on_device",
    "kernel_unloader_s0_run_on_device",
    "kernel_feeder_s0_run_on_device",
    "kernel_O_s0_run_on_device",
    "kernel_collector_gather_O_run_on_device"};

double compute_kernel_execution_time(cl_event &event, double &start_d, double &end_d) {
    cl_ulong start, end;

    clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_END, sizeof(cl_ulong), &end, NULL);
    clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_START, sizeof(cl_ulong), &start, NULL);

    start_d = (double)1.0e-9 * start;
    end_d = (double)1.0e-9 * end;
    //return (double)(end-start);
    return (double)1.0e-9 * (end - start); // nanoseconds to seconds
}

void initialize_array(float *array) {
#if SIZE == 1
    TYPE data[] = {2};  // Expect output: 2
#elif SIZE == 2
    TYPE data[] = { 1, 3, 4, 5}; // Expect output: 1 3; 4 -7
#elif SIZE == 3
    TYPE data[] = { 1, 3, 9, 4, 6, 10, 2, 5, 3}; // Expect output: 1 3 9; 4 -6 -26; 2 0.17 -10.67
#elif SIZE == 4
    TYPE data[] = { 1, 4, 5, 2, 2, 3, 6, 7, 3, 5, 8, 9, 5, 2, 1, 12}; // Expect output: 1 4 5 2; 2 -5 -4 3; 3 1.4 -1.4 -1.2; 5 3.6 6.86 -0.57
#elif SIZE == 5
    TYPE data[] = { 2, 4, 5, 2, 5, 1, 4, 6, 7, 6, 3, 5, 5, 9, 7, 5, 2, 1, 6, 8, 5, 6, 7, 8, 7}; // Expect output: 2 4 5 2 5; 0.5 2 3.5 6 3.5; 1.5 -0.5 -0.75 9 1.25; 2.5 -4 -3.33 55 13.67; 2.5 -2 -2 0.6 -4.2
#elif SIZE == 6
    TYPE data[] = { 3, 1, 2, 5, 4, 6, 1, 2, 3, 7, 6, 8, 3, 4, 5, 9, 7, 7, 5, 10, 1, 2, 8, 8, 5, 6, 5, 5, 10, 9, 6, 3, 7, 9, 11, 12};
#else
    TYPE data[SIZE*SIZE];
    for (int j = 0; j < SIZE; j++) {
        for (int i = 0; i < SIZE; i++) {
            data[i + SIZE * j] = (i + 1)*(j + 1) + log(i * j + 1);
        }
    }
#endif
    
        for (int j = 0; j < SIZE; j++) {
            for (int i = 0; i < SIZE; i++) {
                    array[j*SIZE+i] = data[i + j * SIZE];
                }
            }
}

int main() {
    float *A, *Z;
    long int num_elem_A = (long int)BB * SIZE * SIZE * B;
    long int num_elem_Z = (long int)BB * SIZE * SIZE * B;
    if ((A = (float *)acl_aligned_malloc(num_elem_A * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix A");
    }
    if ((Z = (float *)acl_aligned_malloc(num_elem_Z * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix C");
    }

    initialize_array(A);

    // Serialize A
    float *serialized_A;
    if ((serialized_A = (float *)acl_aligned_malloc(num_elem_A * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix serialized_A");
    }

    long int addr = 0;
    for (int b = 0; b < B; b++)
        for (int i = 0; i < SIZE; i++)
            for (int j = 0; j < SIZE; j++) 
                for (int bb = 0; bb < BB; bb++){
                    serialized_A[addr++] = A[j*SIZE+i];
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
    cl_mem output_Z_buf;

    DPRINTF("\n===== Host-CPU transferring W and X to the FPGA device global memory (DDR4) via PCIe ======\n\n");
    input_A_buf = clCreateBuffer(
        context,
        //CL_MEM_READ_ONLY | CL_MEM_BANK_1_ALTERA,
        CL_MEM_READ_ONLY,
        num_elem_A * sizeof(cl_float),
        NULL,
        &status);
    CHECK(status);

    output_Z_buf = clCreateBuffer(
        context,
        //CL_MEM_WRITE_ONLY | CL_MEM_BANK_1_ALTERA,
        CL_MEM_WRITE_ONLY,
        num_elem_Z * sizeof(cl_float),
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

    // serialized_A
    status = clSetKernelArg(
        kernel[0],
        0,
        sizeof(cl_mem),
        (void *)&input_A_buf);
    CHECK(status);

    // result Z
    status = clSetKernelArg(
        kernel[1],
        0,
        sizeof(cl_mem),
        (void *)&output_Z_buf);
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
    printf("  FPGA Convolution exec time\t\t= %.5f s\n", k_overall_exec_time);

    // multiplied by 1.0e-9 to get G-FLOPs
    printf("\n");

    double num_operations = (double)B * BB * SIZE * (SIZE - 1) * (4 * SIZE + 7) / 6;

    printf("  # operations = %.0f\n", num_operations );
    printf("  Throughput: %.5f GFLOPS\n", (double)1.0e-9 * num_operations / k_overall_exec_time);

    DPRINTF("\n===== Host-CPU transferring result matrix C from the FPGA device global memory (DDR4) via PCIe ======\n\n");

    // Read the results back from the device, blocking read
    float *serialized_Z;
    if ((serialized_Z = (float *)acl_aligned_malloc(num_elem_Z * sizeof(float))) == NULL) {
        perror("Failed malloc of matrix serialized_Z");
    }

    clEnqueueReadBuffer(
        //cmdQueue[KID_DRAIN_MAT_C],
        cmdQueue[NUM_KERNELS_TO_CREATE], // using a special queue for reading buffer C
        output_Z_buf,
        CL_TRUE,
        0,
        num_elem_Z * sizeof(cl_float),
        serialized_Z,
        0,
        NULL,
        NULL);
    CHECK(status);

    // Deserialize Z
    addr = 0;
    for (int b = 0; b < B; b++)
        for (int i = 0; i < SIZE; i++)
            for (int j = 0; j < SIZE; j++) 
                for (int bb = 0; bb < BB; bb++){
                    Z[bb + i*BB + j*SIZE*BB + b*SIZE*SIZE*BB] = serialized_Z[addr++];
                }

    for (int j = 0; j < SIZE; j++) {
      for (int i = 0; i < SIZE; i++) {
        printf("%5.2f ", A[j * SIZE + i]);
      }
      printf("\n");
    }
    bool passed = 1;

    printf("*** L * U in C style (Input):\n");
    for (int j = 0; j < SIZE; j++) {
      for (int i = 0; i < SIZE; i++) {
        TYPE sum = 0;
        // j'th row of O times i'th column of O
        for (int k = 0; k < SIZE; k++) {
            TYPE l, u;
            l = (j > k) ? Z[(j * SIZE * BB) + k*BB] : (j == k) ? 1 : 0;
            u = (k > i) ? 0 : Z[(k * SIZE*BB) + i*BB];
            sum += l * u;
        }
        bool correct = (abs(sum - A[j * SIZE + i]) < 1e-2);
        printf("%5.2f (%5.2f%s)", sum, A[j * SIZE+ i], correct ? "" : " !!");
        passed = passed && correct;
      }
      printf("\n");
    }

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
