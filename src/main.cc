#include <stdio.h>
#include <time.h>
#include <iostream>
#include "../inc/chCommandLine.h"
#include "../inc/chTimer.hpp"

#include <MergeSort.cu>

const static int DEFAULT_N = 100;
// using namespace std;

// function prototypes
template <typename type> void init_tab(type* array, int n);
template <typename type> void cpu_tri(type* array, int n);
template <typename type> void print_tab(type* array, int n);
template <typename type> bool is_sorted(type* array, int n);

void print_help( char* argv);


//main
int main(int argc, char* argv[]){
	
	// print help
	bool      help = chCommandLineGetBool("h", argc, argv);
	if(!help) help = chCommandLineGetBool("help", argc, argv);
	if(help)  print_help(argv[0]);

	// size
	int n = -1;
	chCommandLineGet<int>(&n, "n", argc, argv);
	chCommandLineGet<int>(&n, "size", argc, argv);
	n = (n!=-1)? n:DEFAULT_N;

	// allouer mémoire et initialiser
		// cpu
	int* cpu_v = (int*)malloc(n*sizeof(int));
	init_tab(cpu_v, n);

		// gpu
	int na, nb;
	na = floor(n/2);
	nb = ceil(n/2);
	std::cout << na << " " << nb << std::endl;

	int *A, *B, *C;
	cudaMalloc(&A, na*sizeof(int));
	cudaMalloc(&B, nb*sizeof(int));
	cudaMalloc(&C, n*sizeof(int));

	cpu_tri(cpu_v, na);
	cpu_tri(cpu_v+na, nb);	
	cudaMemcpy(A, v, na*sizeof(int));
	cudaMemcpy(B, v+na, nb*sizeof(int));

	print_tab(cpu_v, n);

	// trier et chronométrer
	int gridSize = 1;
	int blockSize = 4;

	Partitionning<int><<<gridSize, blockSize>>>(A, na, B, nb, C);


	// afficher

	// return 0
	return 0;
}

template <typename type>
void init_tab(type* array, int n) {
	// génère n entiers aléatoirements dans array
	for(int i=0;i<n;i++){
		array[i]=rand()%10;
	}
}

template <typename type>
void cpu_tri(type* array, int n) {
	bool swap=true;
	for(int i=0;(i<n)&&swap;i++){
		swap = false;
		for(int j=0;(j<n-i-1);j++){
			if(array[j]>array[j+1]){
				int tmp = array[j];
				array[j] = array[j+1];
				array[j+1] = tmp;
				swap = true;
			}
		}
	}
}

template <typename type>
bool is_sorted(type* array, int n) {
	for(int i=0; i<n; i++) {
		if(array[i]>array[i+1]) return false;
	}
	return true;
}


template <typename type>
void print_tab(type* array, int n) {
	for(int i=0; i<n; i++) {
		std::cout << array[i] << " ";
	}
	std::cout << std::endl;
}

void print_help( char* argv) {
/*
	cout	<< "Help:" << endl
		<< "  Usage: " << endl
		<< "  " << argv << " [options][-n <repressor-number> ]" << endl
		<< endl
		<< "  -n|--repressor-number" << endl
		<< "      number of repressors to be used, must be an odd integer" << endl
		<< endl;
*/
}
