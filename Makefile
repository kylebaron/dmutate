SHELL := /bin/bash
LIBDIR=/Users/kyleb/Rlibs/lib
PACKAGE=dmutate
VERSION=$(shell grep Version rdev/DESCRIPTION |awk '{print $$2}')
TARBALL=${PACKAGE}_${VERSION}.tar.gz
PKGDIR=rdev/
CHKDIR=Rchecks

## Set libPaths:
export R_LIBS=${LIBDIR}

ec:
	echo ${VERSION}

all:
	make doc
	make build
	make install

.PHONY: doc
doc:
	Rscript -e 'library(devtools); document("rdev")'

build:
	R CMD build --md5 $(PKGDIR)


install:
	R CMD INSTALL --install-tests ${TARBALL}

install-build:
	R CMD INSTALL --build --install-tests ${TARBALL}

check:
	make doc
	make build
	R CMD CHECK ${TARBALL} -o ${CHKDIR}

push:
	make all
	git commit -am "make push"
	git push -u origin master


