#include<iostream>
#include<chCommandLine.h>
#include<cmath>

template <typename type>
int nextpow2(type x) {
        int tmp = 1;
        int exp = 0;
        while (tmp < x) {
                tmp <<= 1;
                exp++;
        }
        return exp;
}

int main(int argc, char* argv[]) {

	// size
        int n = -1;
        chCommandLineGet<int>(&n, "n", argc, argv);
        chCommandLineGet<int>(&n, "size", argc, argv);
        n = (n!=-1)? n:200;	

	int exp = nextpow2<int>(n);

	std::cout << "n = " << n << " < 2^" << exp << " = " << std::pow(2,exp) << std::endl;
	std::cout << std::endl;

	int p = exp - 6;
	int s = 6;
	
	std::cout << "p=" << p << "\ts=" << s << std::endl;
	std::cout << "2^p=" << std::pow(2,p) << "\t2^s=" << std::pow(2,s) << std::endl;
	std::cout << std::endl;

	std::cout << "n < " << std::ceil( (float)n/std::pow(2,s) ) << "*" << std::pow(2,s) 
		<< " = " << std::ceil( (float)n/std::pow(2,s) ) * std::pow(2,s) << std::endl;

	std::cout << "2^s * 2^p -n = " <<  std::ceil( (float)n/std::pow(2,s) ) * std::pow(2,s) - n << std::endl;
}
