#include <stdio.h>
#include <time.h>
#include <cuda_runtime.h>
#include <cuda.h>

template <typename type>
__host__ __device__ void merge(type* A, int na, int aid, type* B, int nb, int bid,
				type* C, int cid, int load) {

	for(int t=0; t<load; t++) {
		if(aid<na && bid<nb) { // this should always be true...
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
__global__ void merge2(type* A, int na, int aid, type* B, int nb, int bid,
				type* C, int cid, int load) {

	//int tid = blockIdx.x*blockDim.x+threadIdx.x;	// thread ID
	int index = cid+threadIdx.x;					// starting index in C
	int a, b, offset;
	
	while( index < (cid+load) ) {
		if(index==cid) {
			// thread 0 always starts at (0,0)
			a = aid;	b = bid;
		}
		else {
			// search zone: indices of the top-right cell of the central diagonal
			int a_top = aid+threadIdx.x;	// col index (in A)
			int b_top = bid;				// row index (in B)
			int a_bot = aid;				// top left col index
			
			if(a_top<na && b_top<nb) {	// this should always be true
				// binary search (dichotomy)
		
				while(true) {
					// get mid cell of the (sub-)diagonal
					offset = (a_top - a_bot) / 2;
					a = a_top - offset;		b = b_top + offset;

					// check if point found
					if(A[a]>B[b-1]){
						if(A[a-1]<=B[b]){
							// point found
							break;
						}
						else{
							// restrict search to lower half
							a_top = a-1;	b_top = b+1;
						}
					}
					else{
						// restrict search to upper half
						a_bot = a+1;
					}
				}
			}
			
			printf("[%d] (%d,%d)\n", index, a, b);
			if(A[a] < B[b]) {
				C[index] = A[a];
			}
			else {
				C[index] = B[b];
			}
		}
		index+=blockDim.x;
	}
				
}

template <typename type>
__global__ void partitionning(type* A, int na, type* B, int nb, type* C){

	int nbThreads = blockDim.x * gridDim.x;			// number of threads
	int tid = blockIdx.x*blockDim.x+threadIdx.x;	// thread ID
	int load = (na+nb)/nbThreads;					// size of each subarray
	int index = tid*load;							// starting index in C

	// search zone: indices of the top-right cell of the central diagonal
	int a_top = (index>na)? na:index;		// col index (in A)
	int b_top = (index>na)? index-na:0;		// row index (in B)
	int a_bot = b_top;						// top left col index

	// binary search (dichotomy)
	int a, b, offset, aid, bid;
	if(tid ==0) {
		// thread 0 always starts at (0,0)
		aid = 0;	bid = 0;
	}
	else {
		while(true) {
			// get mid cell of the (sub-)diagonal
			offset = (a_top - a_bot) / 2;
			a = a_top - offset;		b = b_top + offset;

			// check if point found
			if(A[a]>B[b-1]){
				if(A[a-1]<=B[b]){
					// point found
					aid = a;	bid = b;	break;
				}
				else{
					// restrict search to lower half
					a_top = a-1;	b_top = b+1;
				}
			}
			else{
				// restrict search to upper half
				a_bot = a+1;
			}
		}
	}

	//printf("[%d] (%d,%d); %d\n", tid, aid, bid, index);
	//merge(A, na, aid, B, nb, bid, C, index, load);
	merge2<<<1,3>>>(A, na, aid, B, nb, bid, C, index, load);

}
