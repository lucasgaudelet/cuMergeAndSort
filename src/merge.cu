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
		else if(index==na+nb-1) {	// if this is the last element of the array
			a = na-1;	b = nb-1;
			C[index] = (A[a]<B[b])? B[b]:A[a];
		}
		else {	// binary search
			// search zone:
			int a_top = (aid+tid>na)? na:aid+tid;	// col index (in A)
			int b_top = (aid+tid>na)? index-na:bid;	// row index (in B)
			int a_bot = ((a_top-aid)>(nb-b_top))? na+b_top-nb:aid;	// top left col index
			
			printf("\t\t[%d] (%d,%d) %d\n", index, a_top, b_top, a_bot);
			
			if(a_top==na && a_bot == na-1) {
				a = na - 1;	b = b_top+1;
			}
			else if(b_top==nb-1) {
				a = a_top;	b = b_top;
			}
			else {
				int cpt=0;
				while(cpt<1000) {
		
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
					cpt++;
				}
			}
		}

		printf("\t\t[%d] (%d,%d)\n", index, a, b);
		// put the element in C
		if(index!=na+nb-1) {
			if(A[a] < B[b]) {
				C[index] = A[a];
			}
			else {
				C[index] = B[b];
			}
		}
		tid+=blockDim.x;
		index+=blockDim.x;
		
	}
}			
