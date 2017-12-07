#include <stdio.h>
#include <cuda_runtime.h>
#include <cuda.h>

#include <merge.h>

__global__ void partition(int* A, int na, int* B, int nb, int* C);
