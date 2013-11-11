# Mark Anthony Serrano (mmserran@ucsc.edu)
# Makefile for CS104A - asg2

MKFILE    = Makefile
DEPSFILE  = ${MKFILE}.deps
NOINCLUDE = ci clean spotless
NEEDINCL  = ${filter ${NOINCLUDE}, ${MAKECMDGOALS}}
VALGRIND  = valgrind --leak-check=full --show-reachable=yes

#
# Definitions of list of files:
#
HSOURCES  = astree.h  lyutils.h  auxlib.h  stringset.h
CSOURCES  = astree.cc lyutils.cc auxlib.cc stringset.cc main.cc
LSOURCES  = scanner.l
YSOURCES  = parser.y
ETCSRC    = README ${MKFILE} ${DEPSFILE}
CLGEN     = yylex.cc
HYGEN     = yyparse.h
CYGEN     = yyparse.cc
CGENS     = ${CLGEN} ${CYGEN}
ALLGENS   = ${HYGEN} ${CGENS}
EXECBIN   = oc
ALLCSRC   = ${CSOURCES} ${CGENS}
OBJECTS   = ${ALLCSRC:.cc=.o}
LREPORT   = yylex.output
YREPORT   = yyparse.output
IREPORT   = ident.output
REPORTS   = ${LREPORT} ${YREPORT} ${IREPORT}
ALLSRC    = ${ETCSRC} ${YSOURCES} ${LSOURCES} ${HSOURCES} ${CSOURCES}
TESTINS   = ${wildcard test?.in}
LISTSRC   = ${ALLSRC} ${HYGEN}
CLASS     = cmps104a-wm.f13
PROJECT   = asg2

#
# Definitions of the compiler and compilation options:
#
GCC       = g++ -g -O0 -Wall -Wextra -std=gnu++0x
MKDEPS    = g++ -MM -std=gnu++0x

#
# The first target is always ``all'', and hence the default,
# and builds the executable images
#
all : ${EXECBIN}

#
# Build the executable image from the object files.
#
${EXECBIN} : ${OBJECTS}
	${GCC} -o${EXECBIN} ${OBJECTS}
	ident ${OBJECTS} ${EXECBIN} >${IREPORT}

#
# Build an object file form a C source file.
#
%.o : %.cc
	${GCC} -c $<


#
# Build the scanner.
#
${CLGEN} : ${LSOURCES}
	flex --outfile=${CLGEN} ${LSOURCES} 2>${LREPORT}
	- grep -v '^  ' ${LREPORT}

#
# Build the parser.
#
${CYGEN} ${HYGEN} : ${YSOURCES}
	bison --defines=${HYGEN} --output=${CYGEN} ${YSOURCES}

#
# Check sources into GIT subdirectory.
#
ci:
	make spotless
	git add *
	git commit -m "MSG"
	git push origin master

#
# Clean and spotless remove generated files.
#
clean :
	- rm ${OBJECTS} ${ALLGENS} ${REPORTS} ${DEPSFILE}

spotless : clean
	- rm ${EXECBIN}


#
# Build the dependencies file using the C preprocessor
#
deps : ${ALLCSRC}
	@ echo "# ${DEPSFILE} created `date` by ${MAKE}" >${DEPSFILE}
	${MKDEPS} ${ALLCSRC} >>${DEPSFILE}

${DEPSFILE} :
	@ touch ${DEPSFILE}
	${MAKE} --no-print-directory deps

#
# Make sure to submit to correct class/assignment!!
#
submit : ${ALLSOURCES}
	submit ${CLASS} ${PROJECT} *

	
ifeq "${NEEDINCL}" ""
include ${DEPSFILE}
endif

