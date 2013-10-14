# Mark Anthony Serrano (mmserran@ucsc.edu)
# Makefile for CS104A - asg1

GPP = g++ -g -O0 -Wall -Wextra -std=gnu++0x
GRIND = valgrind --leak-check=full --show-reachable=yes

all : oc 

oc : main.o auxlib.o stringset.o
	$(GPP) main.o auxlib.o stringset.o -o oc

%.o : %.cc
	${GPP} -c $<

clean:
	rm -rf *.str main.o stringset.o auxlib.o

spotless:
	rm -rf *.str oc main.o stringset.o auxlib.o
	
ci:
	make spotless
	git add *
	git commit -m "Makefile generated commit"
	git push origin master

gs:
	$(GRIND) ./oc -ly 01-hello.oc

deps : auxlib.o stringset.o
	${GPP} -c auxlib.cc
	${GPP} -c stringset.cc

# Dependencies
main.o : main.cc
auxlib.o : auxlib.cc auxlib.h
stringset.o : stringset.cc stringset.h

# Collection of tests
test1:
	./oc -ly -@c 01-hello.oc
test2:
	./oc -ly -@c -D#foo 01-hello.oc
test3:
	./oc -ly -@o 01-hello.oc