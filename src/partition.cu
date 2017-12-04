#include <partition.h>

__global__ void partition(int* A, int na, int* B, int nb, int* C){

	int nbThreads = blockDim.x * gridDim.x;		// number of threads
	int tid = blockIdx.x*blockDim.x+threadIdx.x;	// thread ID
	int load = (na+nb)/nbThreads;			// size of each subarray
	int index = tid*load;				// starting index in C

	// search zone: indices of the top-right cell of the central diagonal
	int a_top = (index>na)? na:index;		// col index (in A)
	int b_top = (index>na)? index-na:0;		// row index (in B)
	int a_bot = b_top;				// top left col index

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

	printf("[%d] (%d,%d); %d\n", tid, aid, bid, index);
	merge(A, na, aid, B, nb, bid, C, index, load);
}


__global__ void partition2(int* A, int na, int* B, int nb, int* C) {

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

	printf("[%d] (%d,%d); %d\n", tid, aid, bid, index);

	if(load<1024)	merge2<<<1,load>>>(A, na, aid, B, nb, bid, C, index, load);
	else		merge2<<<1,1024>>>(A, na, aid, B, nb, bid, C, index, load);
}
