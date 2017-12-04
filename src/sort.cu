#include <sort.h>

__host__ __device__ void bubbleSort(int* array, int size) {
      bool swapped = true;
      int j = 0;
      int tmp;
      while(swapped) {
            swapped = false;
            j++;
            for(int i=0; i<size-j; i++) {
                  if(array[i] > array[i+1]) {
                        tmp = array[i];
                        array[i] = array[i+1];
                        array[i+1] = tmp;
                        swapped = true;
                  }
            }
      }
}

__global__ void initial_sort(int* array, int size, int grain_size) {

	int tid = blockIdx.x*blockDim.x + threadIdx.x; // thread ID
	int index = tid*grain_size;

	while(index < size) {
		int n = (index+grain_size>size)? grain_size-index+size:grain_size;
		bubbleSort(array+index,n);
		index+=gridDim.x*blockDim.x*grain_size;
	}
}
