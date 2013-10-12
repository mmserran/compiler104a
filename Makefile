# Mark Anthony Serrano (mmserran@ucsc.edu)
# Makefile for CMPS 101 pa2  

GPP = g++ -g -O0 -Wall
GRIND = valgrind --leak-check=full --show-reachable=yes

all : oc 

oc : main.o
	$(GPP) main.o -o oc

%.o : %.cc
	${GPP} -c $<

clean:
	rm -rf *.str oc main.o stringset.o auxlib.o

test:
	./oc -ly pwd/test/01-hello.oc
	
gs:
	$(GRIND) ./oc -ly pwd/test/01-hello.oc

main.o : main.cc
auxlib.o : auxlib.cc auxlib.h
stringset.o : stringset.cc stringset.h