#include <MergeSort.h>

//template <typename type>
//__host__ __device__ void merge(type* A, int aid, type* B, int bid, type* C, int cid, int load) {
__host__ __device__ void merge(int* A, int aid, int* B, int bid, int* C, int cid, int load) {
	for(int t=0; t<load; t++) {
		if(A[aid] < B[bid]) {
			C[cid-t] = A[aid];	aid++;
		}
		else{
			C[cid-t] = B[bid];	bid++;
		}
	}
}

//template <typename type>
//__global__ void partitionning(type* A, int na, type* B, int nb, type* C, int* Adiag, int* Bdiag){
__global__ void partitionning(int* A, int na, int* B, int nb, int* C, int* Adiag, int* Bdiag){

	printf("in\n");

	int nbThreads = blockDim.x * gridDim.x;
	
	int tid = blockIdx.x*blockDim.x+threadIdx.x;	// thread ID
	int load = (na+nb)/nbThreads;			// the size of each thread's sub-array
	int index = tid*load;				// starting index in C
	
	if(tid==0) {
		Bdiag[nbThreads-1] = nb; 
		Adiag[nbThreads-1] = na;
	}

	printf("[%d] in\n", tid);

	// col index (in A) and row index (in B) of the top-right cell of the central diag
	int a_top = (index>na)? na:index;		
	int b_top = (index>na)? na-index:0;	
	int a_bot = b_top;	// top left col index

	// binary search
	int a,b,offset;
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

	printf("[%d] merge\n", tid);
	merge(A, Adiag[tid], B, Bdiag[tid], C, index, load);
	printf("[%d] out\n", tid);

}


