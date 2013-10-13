# Mark Anthony Serrano (mmserran@ucsc.edu)
# Makefile for CMPS 101 pa2  

GPP = g++ -g -O0 -Wall -Wextra -std=gnu++0x
GRIND = valgrind --leak-check=full --show-reachable=yes

all : oc 

oc : main.o stringset.o
	$(GPP) main.o stringset.o -o oc

%.o : %.cc
	${GPP} -c $<

clean:
	rm -rf *.str oc main.o stringset.o auxlib.o

test:
	./oc -ly 01-hello.oc
	
gs:
	$(GRIND) ./oc -ly pwd/test/01-hello.oc

main.o : main.cc
auxlib.o : auxlib.cc auxlib.h
stringset.o : stringset.cc stringset.h
