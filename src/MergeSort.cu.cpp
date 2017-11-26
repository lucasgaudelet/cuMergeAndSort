#include <stdio.h>
#include <time.h>



__host__ __device__ void merge(type* A, int aid, type* B, int bid, type* C, int cid, int load) {
	for(int t=0; t<load; t++) {
		if(A[aid] < B[bid]) {
			C[cid-t] = A[aid];	aid++;
		}
		else{
			C[cid-t] = B[bid];	bid++;
		}
	}
}

template <typename type>
__global__void Partitionning(type* A, int na, type* B, int nb, type* C){
	int nbThreads = blockDim.x * gridDim.x;

	int Adiag[nbThreads-1] = na;
	int Bdiag[nbThreads-1] = nb; 
	
	int tid = blockIdx.x*blockDim.x+threadIdx.x;	// thread ID
	int load = (na+nb)/nbThreads;					// the size of each thread's sub-array
	int index = tid*load;							// starting index in C

	// col index (in A) and row index (in B) of the top-right cell of the central diag
	int a_top = (index>na)? na:index;		
	int b_top = (index>na)? na-index:0;	
	int a_bot = b_top;	// top left col index

	// binary search
	int a,b;
	while(true){
		offset = (a_top - a_bot) / 2;
		a = a_top - offset;
		b = b_top + offset;

		if(A[a]>B[b-1]){
			if(A[a-1]<=B[b]){
				Adiag[tid] = a;
				Bdiag[tid] = b;
				break;
			}
			else{
				a_top = a-1;
				b_top = a+1;
			}
		}
		else{
			a_bot = a+1;
		}

	}

	merge(A, Adiag[tid], B, Bdiag[tid], C, index, load);

}


