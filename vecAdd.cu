//
// Created by Palash on 19-02-2018.
//

#include <stdio.h>
#include <ctime>
#include <malloc.h>
#include "vecAdd.h"
#include "cudaHeaders.h"

__global__ void vecAdd(float *a, float *b, float *c, int size) {
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    printf("Hello from block %d, thread %d\n", blockIdx.x, threadIdx.x);

    if (i < size)
        *(c + i) = *(a + i) + *(b + i);
}


int doVecAdd() {
    cudaEvent_t begin, begin_kernel, stop_kernel, stop;
    cudaEventCreate(&begin);
    cudaEventCreate(&begin_kernel);
    cudaEventCreate(&stop_kernel);
    cudaEventCreate(&stop);

    float *a, *b, *c;
    int size = 10;


    a = (float *)malloc(sizeof(float) * size);
    b = (float *)malloc(sizeof(float) * size);
    c = (float *)malloc(sizeof(float) * size);

    int j = 0;
    for (int i = 0; i<size; i++) {
        *(a + i) = j++;
        *(b + i) = j++;
    }

    float *d_a, *d_b, *d_c;

    cudaMalloc(&d_a, size*sizeof(float));
    cudaMalloc(&d_b, size*sizeof(float));
    cudaMalloc(&d_c, size*sizeof(float));

    cudaEventRecord(begin);

    cudaMemcpy(d_a, a, size*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size*sizeof(float), cudaMemcpyHostToDevice);

    cudaEventRecord(begin_kernel);

    vecAdd <<<1, 1024 >>>(d_a, d_b, d_c, size);

    cudaEventRecord(stop_kernel);
    gpuErrchk(cudaPeekAtLastError());

    cudaMemcpy(c, d_c, size*sizeof(float), cudaMemcpyDeviceToHost);

    cudaEventRecord(stop);
    cudaEventSynchronize(stop_kernel);
    cudaEventSynchronize(stop);
    float kernelTime, totalTime; // Initialize elapsedTime;
    cudaEventElapsedTime(&kernelTime, begin_kernel, stop_kernel);
    cudaEventElapsedTime(&totalTime, begin, stop);
    printf("Time for KERNEL execution is: %fms\n", kernelTime);
    printf("Total time is: %fms\n", totalTime);

    printf("A vector:\n");
    for(int i=0; i<size; i++)
    printf("%.3f ", *(a+i));
    printf("\n");

    printf("B vector:\n");
    for(int i=0; i<size; i++)
    printf("%.3f ",*(b+i));
    printf("\n");

    printf("C vector:\n");
    for(int i=0; i<size; i++)
    printf("%.3f ", *(c+i));
    printf("\n");

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}
