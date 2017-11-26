SRC=src/main.c src/MergeSort.cu
OBJ=main.o MergeSort.o

CC=nvcc
CFLAGS=-Wall -std=c++11

INC=-I./inc -I./src
LIB=-L./lib 
LDFLAGS=$(INC) $(LIB)

.PHONY: all
all: ./bin/ms

%.o: src/%.cc
	$(CC) $(LDFLAGS) $(CFLAGS) -c -o $@ $<

%.o: src/%.cu
	$(CC) $(LDFLAGS) $(CFLAGS) -c -o $@ $<

./bin/ms: $(OBJ)
	$(CC) $(LDFLAGS) $(CFLAGS)  -o $@ $^


.PHONY: clean
clean:
	rm -f *.o
	rm -f bin/*

exec:
	time ./bin/repressilator