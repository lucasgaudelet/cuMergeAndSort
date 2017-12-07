#pragma once
#include<iostream>

// function prototypes
/*template <typename type> void init_array(type* array, int n, int mod=0);
template <typename type> void print_array(type* array, int n);
template <typename type> bool is_sorted(type* array, int n);
template <typename type> int nextpow2(type x);
*/
// code

template <typename type>
void init_array(type* array, int n, int mod=0) {

        switch(mod) {
        case 0:
                for(int i=0;i<n;i++){
                        array[i]=rand()%10;
                }
                break;

        case 1:
                for(int i=0;i<n;i++){
                        array[i]=i;
                }
                break;
        }
}

template <typename type>
bool is_sorted(type* array, int n) {
        for(int i=0; i<n-1; i++) {
                if(array[i]>array[i+1]) return false;
        }
        return true;
}

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


template <typename type>
int get_subarray_size(int n, int max_size=100) {
	int s = 1;
	int grain=0;
	int max = max_size;

	while( std::ceil((float)n/grain) != std::pow(2,s) ) {
		s = 1;
		grain = std::ceil((float)n/std::pow(2,s));
		max += max_size;
		while( grain>max ) {
			s++;
			grain = std::ceil((float)n/std::pow(2,s));
		}
	}
	return grain;
}

template <typename type>
void print_array(type* array, int n) {
        for(int i=0; i<n; i++) {
                std::cout << array[i] << " ";
        }
        std::cout << std::endl;
}
