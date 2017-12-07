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


const static int DEFAULT_N = 100;
const static int DEFAULT_PARTSIZE = 32;

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

	// size of partition
	int partSize = -1;
	chCommandLineGet<int>(&partSize, "p", argc, argv);
	chCommandLineGet<int>(&partSize, "partSize", argc, argv);
	partSize = (partSize!=-1)? partSize:DEFAULT_PARTSIZE;

	// memory allocation and initialisation
	std::cout << "Initialization...\t" << std::flush;
	int* cpu_v = (int*)malloc(n*sizeof(int));
	int* out = (int*)malloc(n*sizeof(int));
	init_array(cpu_v, n);
	std::cout << "done" << std::endl;

	// gpu sort
	std::cout << "gpu sort...\t\t" << std::flush;
	ChTimer kernel;
	kernel.start();
	msWrapper(cpu_v, n, out, partSize);
	kernel.stop();
	std::cout << "done" << std::endl;


	// compare results
	ChTimer cpuTimer;
	bool compare_cpu = (chCommandLineGetBool("c", argc, argv))?
		true:chCommandLineGetBool("compare-cpu", argc, argv);
	if(compare_cpu) {
		std::cout << "cpu sort...\t" << std::flush;
		cpuTimer.start();
		bubbleSort(cpu_v, n);
		cpuTimer.stop();
		std::cout << "done" << std::endl << std::endl;
	}

	// display performances
	std::cout << "Results...\t" << std::flush;
	std::cout << "\tsorted=" << is_sorted(out, n) << std::endl;
	std::cout << "\tgpu time: " << 1e3*kernel.getTime() << "ms" << std::endl;
	if(compare_cpu)
		std::cout <<"\tcpu time: "<<1e3*cpuTimer.getTime()<<"ms"<<std::endl;

	// application thats's very nice and all
	/*float a = 0;
	std::cout << "Entrez un pourcentage * souhaité pour connaître l'année de panne correspondant: " <<std::endl;
	std::cin >> a;

	int result = floor(a/100*n);

	std::cout << std::endl;
	std::cout << "Il y a " << a << "% des appareils qui tombent en panne avant " << out[result]<< " ans" << std::endl;
	std::cout << std::endl;
	std::cout << std::endl;
	std::cout << "Informations complémentaires:" << std::endl;
	std::cout << "25% des appareils tombent en panne avant : \t" << out[n/4] <<" ans"<< std::endl;
	std::cout << "la durée de vie médiane des appareils est : \t" << out[n/2] <<" ans"<< std::endl;
	std::cout << "25% des appareils tombent en panne après : \t" << out[3*n/4] << " ans" << std::endl;
	*/

	//free
	free(cpu_v);	free(out);

	return 0;
}

void print_help( char* argv) {

	std::cout << "Help:" << std::endl
		<< "  Usage: " << std::endl
		<< "  " << argv << " [options][-n <size>][-b <blockSize>]" << std::endl
		<< std::endl
		<< "  -n|--size" << std::endl
		<< "      size of input array" << std::endl
		<< "  -p|--partSize" << std::endl
		<< "      size of each partition" << std::endl
		<< std::endl;

}
