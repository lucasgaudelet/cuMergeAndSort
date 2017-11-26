#include <stdio.h>
#include <time.h>
#include <cuda_runtime.h>
#include <cuda.h>

//template <typename type>
//__host__ __device__ void merge(type* A, int aid, type* B, int bid, type* C, int cid, int load) {
__host__ __device__ void merge(int* A, int aid, int* B, int bid, int* C, int cid, int load);

//template <typename type>
//__global__ void partitionning(type* A, int na, type* B, int nb, type* C, int* Adiag, int* Bdiag){
__global__ void partitionning(int* A, int na, int* B, int nb, int* C, int* Adiag, int* Bdiag);
