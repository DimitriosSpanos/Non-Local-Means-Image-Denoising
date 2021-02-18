SHELL := /bin/bash # Use bash syntax

CC = sm_30
CFLAGS = -O3
NVCC	= nvcc -o
ARGS	= -ptx

default: all

V0:
	gcc $(CFLAGS) -o V0 V0.c -lm

V1:
	$(NVCC) V1 V1.cu

V2:
	$(NVCC) V2 V2.cu


.PHONY: clean

all: V0 V1 V2


clean:
	rm -f V0 V1 V2