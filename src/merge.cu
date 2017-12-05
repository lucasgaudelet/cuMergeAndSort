#include <merge.h>

__host__ __device__ void merge(int* A, int na, int aid, int* B, int nb, int bid,
				int* C, int cid, int load) {

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


__global__ void merge2(int* A, int na, int aid, int* B, int nb, int bid,
				int* C, int cid, int load) {

	if(blockIdx.x==0 && threadIdx.x==0) printf("\t\tMerge %d x %d\n", gridDim.x, blockDim.x);

	int tid = threadIdx.x;	// thread ID
	int index = cid+tid;	// starting index in C
	int a, b, offset;
	
	while( index < (cid+load) ) {	// batch loop

		// find path
		if(index==cid) { // thread 0 always starts at (0,0)
			a = aid;	b = bid;
		}
		if(index==na+nb-1) {	// if this is the last element of the array
			a = na-1;	b = nb-1;
		}
		else {	// binary search
			// search zone:
			int a_top = (aid+tid>na)? na:aid+tid;	// col index (in A)
			int b_top = (aid+tid>na)? index-na:bid;	// row index (in B)
			int a_bot = b_top;	// top left col index
			
			while(true) {
		
				// get mid cell of the (sub-)diagonal
				offset = (a_top - a_bot) / 2;
				a = a_top - offset;		b = b_top + offset;

				if(A[a]>B[b-1]){
					if(A[a-1]<=B[b]){
						break;	// point found
					}
					else{ // restrict search to lower half
						a_top = a-1;	b_top = b+1;
					}
				}
				else{ // restrict search to upper half
					a_bot = a+1;
				}
			}
		}

		// put the element in C
		if(A[a] < B[b]) {
			C[index] = A[a];
		}
		else {
			C[index] = B[b];
		}
		tid+=blockDim.x;
		index+=blockDim.x;
	}
}				
