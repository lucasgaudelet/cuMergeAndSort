#include <stdio.h>
#include <cuda_runtime.h>
#include <cuda.h>

__host__ __device__ void merge(int* A, int na, int aid, int* B, int nb, int bid,
				int* C, int cid, int load);

__global__ void merge2(int* A, int na, int aid, int* B, int nb, int bid,
				int* C, int cid, int load);
