#include <MergeSort.h>

template <typename type>
__host__ __device__ void merge(type* A, int na, int aid, type* B, int nb, int bid,
				type* C, int cid, int load) {
//__host__ __device__ void merge(int* A, int na, int aid, int* B, int nb, int bid,
//				int* C, int cid, int load) {
	for(int t=0; t<load; t++) {
		if(aid<na && bid<nb) {
			if(A[aid] < B[bid]) {
				C[cid+t] = A[aid];	aid++;
			}
			else {
				C[cid+t] = B[bid];	bid++;
			}
		}
		else if(aid<na) {
			 C[cid+t] = A[aid];      aid++;
		}
		else if(bid<nb) {
			C[cid+t] = B[bid];      bid++;
		}
	}
}

template <typename type>
__global__ void partitionning(type* A, int na, type* B, int nb, type* C){
//__global__ void partitionning(int* A, int na, int* B, int nb, int* C){

	int nbThreads = blockDim.x * gridDim.x;		// number of threads
	int tid = blockIdx.x*blockDim.x+threadIdx.x;	// thread ID
	int load = (na+nb)/nbThreads;			// size of each subarray
	int index = tid*load;				// starting index in C

	// col index (in A) and row index (in B) of the top-right cell of the 
	// central diagonal
	int a_top = (index>na)? na:index;		
	int b_top = (index>na)? index-na:0;	
	int a_bot = b_top;	// top left col index

	// binary search
	int a, b, offset, aid, bid;
	while(true){
		offset = (a_top - a_bot) / 2;
		a = a_top - offset;
		b = b_top + offset;

		if(A[a]>B[b-1]){
			if(A[a-1]<=B[b]){
				aid = a;
				bid = b;
				break;
			}
			else{
				a_top = a-1;
				b_top = b+1;
			}
		}
		else{
			a_bot = a+1;
		}
	}

	//printf("[%d] (%d,%d); %d\n", tid, aid, bid, index);
	merge(A, na, aid, B, nb, bid, C, index, load);

}
