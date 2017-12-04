SRC=src/main.cu src/merge.cu src/partition.cu src/sort.cu
OBJ=main.o merge.o partition.o sort.o

CC=nvcc
CFLAGS= -std=c++11 -arch=compute_35

INC=-I./inc -I./src
LIB=-L./lib 
LDFLAGS=$(INC) $(LIB)

.PHONY: all
all: ./bin/ms

%.o: src/%.cu 
	$(CC) $(LDFLAGS) $(CFLAGS) --device-c -o $@ $<

./bin/ms: $(OBJ)
	$(CC) $(LDFLAGS) $(CFLAGS)  -o $@ $^


.PHONY: clean
clean:
	rm -f *.o
	rm -f bin/*

