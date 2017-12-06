#include <stdio.h>
#include <time.h>
#include <iostream>
#include <cuda_runtime.h>

#include <chTimer.hpp>
#include <chCommandLine.h>

#include <utils.h>
#include <merge.h>
#include <partition.h>
#include <sort.h>

const static int DEFAULT_N = 12;
const static int DEFAULT_BLOCKSIZE = 4;

void print_help( char* argv);

//main
int main(int argc, char* argv[]){
	
	// print help
	bool      help = chCommandLineGetBool("h", argc, argv);
	if(!help) help = chCommandLineGetBool("help", argc, argv);
	if(help)  {
		print_help(argv[0]); return 0;
	}

	// size
	int n = -1;
	chCommandLineGet<int>(&n, "n", argc, argv);
	chCommandLineGet<int>(&n, "size", argc, argv);
	n = (n!=-1)? n:DEFAULT_N;

	// thread per block
	int blockSize = -1;
	chCommandLineGet<int>(&blockSize, "b", argc, argv);
	chCommandLineGet<int>(&blockSize, "blockSize", argc, argv);
	blockSize = (blockSize!=-1)? blockSize:DEFAULT_BLOCKSIZE;

	// memory allocation
	std::cout << "Memory allocation...\t" << std::flush;
		// cpu
	int* cpu_v = (int*)malloc(n*sizeof(int));
	int* out = (int*)malloc(n*sizeof(int));

		// gpu
	int na, nb;
	na = floor(n/2); 	nb = ceil(n/2);

	int *A, *B, *C;
	cudaMalloc(&A, na*sizeof(int));
	cudaMalloc(&B, nb*sizeof(int));
	cudaMalloc(&C, n*sizeof(int));

	if(!A || !B || !C ) {
		std::cout << "memory alloc error" << std::endl;
		return -1;
	}

	std::cout << "done" << std::endl;
	
	// initialization
	std::cout << "Initialization and H2D...\t" << std::flush;
	
	//init_array(cpu_v, n);
	init_array(cpu_v, na, 0);		init_array(cpu_v+na, nb, 0);
	bubbleSort(cpu_v, na);			bubbleSort(cpu_v+na, nb);
	cudaMemcpy(A, cpu_v, na*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(B, cpu_v+na, nb*sizeof(int), cudaMemcpyHostToDevice);
	
	if(n<70) {
		std::cout << std::endl;
		print_array(cpu_v, na);
		print_array(cpu_v+na, nb);
	}
	std::cout << "done" << std::endl << std::endl;

	// Kernel call
	std::cout << "Partitionning...\t" << std::flush;

	ChTimer kernel;
	kernel.start();
	partition2<<<1, blockSize>>>(A, na, B, nb, C);
	cudaDeviceSynchronize();
	//msWrapper(cpu_v, n, out, 5);
	kernel.stop();
	std::cout << "done" << std::endl;

	//print_array(out, n);

	// D2H
	std::cout << "transfert D2H...\t" << std::flush;
	cudaMemcpy(out, C, n*sizeof(int), cudaMemcpyDeviceToHost);
	std::cout << "done" << std::endl;
	
	// compare results
	ChTimer cpuTimer;
	//string filename;
	bool compare_cpu = (chCommandLineGetBool("c", argc, argv))?
		true:chCommandLineGetBool("compare-cpu", argc, argv);
	//bool store = (chCommandLineGetBool("r", argc, argv))?
	//	true:chCommandLineGetBool("store-results", argc, argv);
	if(compare_cpu) {
		std::cout << "cpu sort...\t" << std::flush;
		cpuTimer.start();
		bubbleSort(cpu_v, n);
		cpuTimer.stop();
		std::cout << "done" << std::endl << std::endl;
	}

	// afficher
	std::cout << "Results...\t" << std::flush;
	if(n<70)	print_array(out, n);
	else		std::cout << std::endl;
	std::cout << "\tsorted=" << is_sorted(out, n) << std::endl;
	std::cout << "\tgpu time: " << 1e3*kernel.getTime() << "ms" << std::endl;
	if(compare_cpu)
		std::cout <<"\tcpu time: "<<1e3*cpuTimer.getTime()<<"ms"<<std::endl;

	//free
	free(cpu_v);	free(out);
	cudaFree(A);	cudaFree(B);
	cudaFree(C);

	return 0;
}

void print_help( char* argv) {

	std::cout << "Help:" << std::endl
		<< "  Usage: " << std::endl
		<< "  " << argv << " [options][-n <size>][-b <blockSize>]" << std::endl
		<< std::endl
		<< "  -n|--size" << std::endl
		<< "      size of input array" << std::endl
		<< "  -b|--blockSize" << std::endl
		<< "      size of thread block, only one block is used" << std::endl
		<< std::endl;

}
