#include <stdio.h>
#include <iostream>
#include <cuda_runtime.h>
#include <cuda.h>

#include <utils.h>
#include <partition.h>

__host__ __device__ void bubbleSort(int* array, int size);

__global__ void initial_sort(int* array, int size, int grain_size);

__global__ void parallel_merge(int* input_array, int size, int* output_array, int subarray_size, int part_size=32);
__global__ void parallel_merge2(int* input_array, int size, int* output_array, int subarray_size, int part_size=32);

void msWrapper(int* input_array, int size, int* output_array, int grain_exp=6);
void msWrapper2(int* input_array, int size, int* output_array, int grain_exp=6);
