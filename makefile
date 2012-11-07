# S2LET package
# Copyright (C) 2012 
# Boris Leistedt & Jason McEwen
# ======================================== #

# Directory for SSHT (required)
SSHTDIR	= ${SSHT}
# Directory for FFTW (required)
FFTWDIR	= ${FFTW}

# Directory for CFITSIO (optional)
CFITSIODIR	= ${CFITSIO}
# Directory for HEALPIX (optional)
HEALPIXDIR	= ${HEALPIX}

# Directory for MATLAB (optional)
MLAB	=  /Applications/MATLAB_R2011b.app
# Directory for DOXYGEN (optional)
#DOXYGEN_PATH = /Applications/Doxygen.app/Contents/Resources/doxygen
DOXYGEN_PATH = doxygen

UNAME 	:= $(shell uname)

# Compilers and options for C
CC	= gcc
OPT	= -Wall -O3 -g -DS2LET_VERSION=\"1.0b1\" -DS2LET_BUILD=\"`svnversion -n .`\"

# Compilers and options for Fortran
FCC	= gfortran
OPTF90 	= -O3 -ffree-form
# To be defined if LGFORTRAN cannot be found in the path
# GFORTRANLIB = /sw/lib/gcc4.6/lib

# Config for dynamic library
ifeq ($(UNAME), Linux)
  DYLIBEXT = so
  DYLIBCMD = cc -flat_namespace -undefined suppress
endif
ifeq ($(UNAME), Darwin)
  DYLIBEXT = dylib
  DYLIBCMD = g++ -flat_namespace -dynamiclib -undefined suppress
endif

# Commands for Healpix
HPXOPT	 = -lgfortran -DGFORTRAN -fno-second-underscore -fopenmp


# ======================================== #

# === MATLAB ===
ifeq ($(UNAME), Linux)
  MLABINC	= ${MLAB}/extern/include
  MLABLIB	= ${MLAB}/extern/lib
  MEXEXT	= mexa64
  MEX 		= ${MLAB}/bin/mex
  MEXFLAGS	= -cxx
endif
ifeq ($(UNAME), Darwin)
  MLABINC	= ${MLAB}/extern/include
  MLABLIB	= ${MLAB}/extern/lib
  MEXEXT	= mexmaci64
  MEX 		= ${MLAB}/bin/mex
  MEXFLAGS	= -cxx
endif

# === S2LET ===
S2LETDIR = .
S2LETLIB = $(S2LETDIR)/lib
S2LETINC = $(S2LETDIR)/include
S2LETBIN = $(S2LETDIR)/bin
S2LETLIBN= s2let
S2LETSRC = $(S2LETDIR)/src/main/c
S2LETOBJ = $(S2LETDIR)/src/main/c
S2LETTESTSRC = $(S2LETDIR)/src/test/c
S2LETTESTOBJ = $(S2LETDIR)/src/test/c
S2LETOBJF90 = $(S2LETDIR)/src/main/f90

# === SSHT ===
SSHTLIB	= $(SSHTDIR)/lib/c
SSHTINC	= $(SSHTDIR)/include/c
SSHTLIBN= ssht

# === FFTW ===
FFTWINC	    = $(FFTWDIR)/include
FFTWLIB     = $(FFTWDIR)/lib
FFTWLIBNM   = fftw3

# === CFITSIO ===
ifneq ($(strip $(CFITSIODIR)),)
CFITSIOINC    = $(CFITSIODIR)/include
CFITSIOLIB     = $(CFITSIODIR)/lib
CFITSIOLIBNM   = cfitsio
endif

# === HEALPIX ===
ifneq ($(strip $(HEALPIXDIR)),)
HEALPIXINC    = $(HEALPIXDIR)/include
HEALPIXLIB     = $(HEALPIXDIR)/lib
HEALPIXLIBN   = healpix
endif

# ======================================== #

S2LETSRCMAT	= $(S2LETDIR)/src/main/matlab
S2LETOBJMAT  = $(S2LETSRCMAT)
S2LETOBJMEX  = $(S2LETSRCMAT)

vpath %.c $(S2LETSRC)
vpath %.c $(S2LETTESTSRC)
vpath %.h $(S2LETINC)
vpath %_mex.c $(S2LETSRCMAT)

LDFLAGS = -L$(S2LETLIB) -l$(S2LETLIBN) -lm -lc -L$(FFTWLIB) -l$(FFTWLIBNM) -L$(SSHTLIB) -l$(SSHTLIBN)

LDFLAGSMEX = -L$(S2LETLIB) -l$(S2LETLIBN) -L$(FFTWLIB) -l$(FFTWLIBNM) -L$(SSHTLIB) -l$(SSHTLIBN) 

FFLAGS  = -I$(FFTWINC) -I$(SSHTINC) -I$(S2LETINC)

S2LETOBJS= $(S2LETOBJ)/s2let_axisym_harm.o 	\
	  $(S2LETOBJ)/s2let_axisym_mw.o 	\
	  $(S2LETOBJ)/s2let_idl_mw.o 	\
	  $(S2LETOBJ)/s2let_math.o 	\
	  $(S2LETOBJ)/s2let_mwtools.o	\
	  $(S2LETOBJ)/s2let_tiling.o

S2LETOBJSMAT = $(S2LETOBJMAT)/s2let_axisym_tiling_mex.o	\
	  $(S2LETOBJMAT)/s2let_mw_axisym_analysis_mex.o		\
	  $(S2LETOBJMAT)/s2let_mw_axisym_synthesis_mex.o	

S2LETOBJSMEX = $(S2LETOBJMEX)/s2let_axisym_tiling_mex.$(MEXEXT)	\
	  $(S2LETOBJMEX)/s2let_mw_axisym_analysis_mex.$(MEXEXT)	\
	  $(S2LETOBJMEX)/s2let_mw_axisym_synthesis_mex.$(MEXEXT)

# ======================================== #

ifneq (,$(wildcard $(HEALPIXLIB)/libhealpix.a))

	S2LETOBJS+= $(S2LETOBJ)/s2let_hpxtools.o
	S2LETOBJS+= $(S2LETOBJ)/s2let_axisym_hpx.o
	S2LETOBJS+= $(S2LETOBJ)/s2let_idl_hpx.o
	S2LETOBJS+= $(S2LETOBJF90)/s2let_hpx.o

	FFLAGS+= -I$(HEALPIXINC)
	LDFLAGS+= -L$(HEALPIXLIB)
	LDFLAGS+= -l$(HEALPIXLIBN)
	LDFLAGS+= -lgfortran -fopenmp 
	ifneq ($(strip $(GFORTRANLIB)),)
	  LDFLAGS+= -L$(GFORTRANLIB)
	endif

	LDFLAGSMEX+= -lgfortran -lgomp
	ifneq ($(strip $(GFORTRANLIB)),)
	LDFLAGSMEX+= -L$(GFORTRANLIB)
	endif
	LDFLAGSMEX+= -L$(HEALPIXLIB)
	LDFLAGSMEX+= -l$(HEALPIXLIBN)

	S2LETOBJSMEX+= $(S2LETOBJMEX)/s2let_hpx_axisym_analysis_mex.$(MEXEXT)
	S2LETOBJSMEX+= $(S2LETOBJMEX)/s2let_hpx_axisym_synthesis_mex.$(MEXEXT)
	S2LETOBJSMAT+= $(S2LETOBJMAT)/s2let_hpx_axisym_analysis_mex.o
	S2LETOBJSMAT+= $(S2LETOBJMAT)/s2let_hpx_axisym_synthesis_mex.o

	S2LETOBJSMEX+= $(S2LETOBJMEX)/s2let_hpx_map2alm_mex.$(MEXEXT)
	S2LETOBJSMEX+= $(S2LETOBJMEX)/s2let_hpx_alm2map_mex.$(MEXEXT)
	S2LETOBJSMAT+= $(S2LETOBJMAT)/s2let_hpx_map2alm_mex.o
	S2LETOBJSMAT+= $(S2LETOBJMAT)/s2let_hpx_alm2map_mex.o

endif

# ======================================== #

ifneq (,$(wildcard $(CFITSIOLIB)/libcfitsio.a))

	S2LETOBJS+= $(S2LETOBJ)/s2let_fitstools.o

	FFLAGS+= -I$(CFITSIOINC)

	LDFLAGS+= -L$(CFITSIOLIB)
	LDFLAGS+= -l$(CFITSIOLIBNM)

	LDFLAGSMEX+= -L$(CFITSIOLIB)
	LDFLAGSMEX+= -l$(CFITSIOLIBNM)

endif

# ======================================== #

$(S2LETOBJ)/%.o: %.c
	$(CC) $(OPT) $(FFLAGS) -c $< -o $@

$(S2LETTESTOBJ)/%.o: %.c
	$(CC) $(OPT) $(FFLAGS) -c $< -o $@

$(S2LETOBJF90)/%.o: $(S2LETOBJF90)/%.f90
	$(FCC) $(OPTF90) $(FFLAGS) $(HPXOPT) -c $< -o $@

$(S2LETOBJMAT)/%_mex.o: %_mex.c $(S2LETLIB)/lib$(S2LETLIBN).a
	$(CC) $(OPT) $(FFLAGS) -c $< -o $@ -I${MLABINC} 

$(S2LETOBJMEX)/%_mex.$(MEXEXT): $(S2LETOBJMAT)/%_mex.o $(S2LETLIB)/lib$(S2LETLIBN).a
	$(MEX) $< -o $@ $(LDFLAGSMEX) $(MEXFLAGS) -L$(MLABLIB)

$(S2LETBIN)/%: $(S2LETOBJ)/%.o $(S2LETLIB)/lib$(S2LETLIBN).a
	$(CC) $(OPT) $< -o $@ $(LDFLAGS)

# ======================================== #

.PHONY: default
default: lib test about tidy

.PHONY: matlab
matlab: $(S2LETOBJSMEX)

.PHONY: all
all: lib matlab bin tidy

bin: test hpx_test hpx_demo denoising_demo axisym_mw_analysis_real axisym_mw_synthesis_real axisym_hpx_analysis_real axisym_hpx_synthesis_real about tidy

.PHONY: lib
lib: $(S2LETLIB)/lib$(S2LETLIBN).a
$(S2LETLIB)/lib$(S2LETLIBN).a: $(S2LETOBJS)
	ar -r $(S2LETLIB)/lib$(S2LETLIBN).a $(S2LETOBJS)

.PHONY: dylib
dylib: $(S2LETLIB)/lib$(S2LETLIBN).$(DYLIBEXT)
$(S2LETLIB)/lib$(S2LETLIBN).$(DYLIBEXT): $(S2LETOBJS)
	$(DYLIBCMD) $(FFLAGS) $(LDFLAGS) -I$(S2LETINC)/idl_export.h -o $(S2LETLIB)/lib$(S2LETLIBN).$(DYLIBEXT) $(S2LETOBJS)
	cp $(S2LETLIB)/lib$(S2LETLIBN).$(DYLIBEXT) $(S2LETDIR)/src/main/resources/lib/darwin_universal/
	cp $(S2LETLIB)/lib$(S2LETLIBN).$(DYLIBEXT) $(S2LETDIR)/target/classes/lib/darwin_universal/

.PHONY: test
test: $(S2LETBIN)/s2let_test
$(S2LETBIN)/s2let_test: $(S2LETTESTOBJ)/s2let_test.o $(S2LETLIB)/lib$(S2LETLIBN).a
	$(CC) $(OPT) $< -o $(S2LETBIN)/s2let_test $(LDFLAGS)

.PHONY: hpx_demo
hpx_demo: $(S2LETBIN)/s2let_hpx_demo
$(S2LETBIN)/s2let_hpx_demo: $(S2LETOBJ)/s2let_hpx_demo.o $(S2LETLIB)/lib$(S2LETLIBN).a
	$(CC) $(OPT) $< -o $(S2LETBIN)/s2let_hpx_demo $(LDFLAGS)

.PHONY: hpx_test
hpx_test: $(S2LETBIN)/s2let_hpx_test
$(S2LETBIN)/s2let_hpx_test: $(S2LETTESTOBJ)/s2let_hpx_test.o $(S2LETLIB)/lib$(S2LETLIBN).a
	$(CC) $(OPT) $< -o $(S2LETBIN)/s2let_hpx_test $(LDFLAGS)


denoising_demo: $(S2LETBIN)/s2let_denoising_demo

axisym_mw_analysis_real: $(S2LETBIN)/s2let_axisym_mw_analysis_real

axisym_mw_synthesis_real: $(S2LETBIN)/s2let_axisym_mw_synthesis_real

axisym_hpx_analysis_real: $(S2LETBIN)/s2let_axisym_hpx_analysis_real

axisym_hpx_synthesis_real: $(S2LETBIN)/s2let_axisym_hpx_synthesis_real

.PHONY: about
about: $(S2LETBIN)/s2let_about
$(S2LETBIN)/s2let_about: $(S2LETOBJ)/s2let_about.o 
	$(CC) $(OPT) $< -o $(S2LETBIN)/s2let_about
	$(S2LETBIN)/s2let_about

.PHONY: doc
doc:
	$(DOXYGEN_PATH) $(S2LETDIR)/src/doxygen.config
.PHONY: cleandoc
cleandoc:
	rm -rf $(S2LETDIR)/doc/c/*

.PHONY: clean
clean:	tidy
	rm -f $(S2LETLIB)/lib$(S2LETLIBN).*
	rm -f $(S2LETOBJMEX)/*_mex.$(MEXEXT)
	rm -f $(S2LETBIN)/*

.PHONY: tidy
tidy:
	rm -f $(S2LETOBJ)/*.o
	rm -f $(S2LETTESTOBJ)/*.o
	rm -f $(S2LETOBJF90)/*.o
	rm -f $(S2LETOBJMEX)/*.o
	rm -f *~ 

# ======================================== #