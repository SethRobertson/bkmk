######################################################################
# $Id: ex.pkg.Makefile,v 1.2 2001/06/18 19:29:32 seth Exp $
#
# Foo package meta Makefile 
#
BK_SUBDIR=libclc libbk

all: install

GROUPTOP=.
GROUPSUBDIR=.
PKGTOP=.
PKGSUBDIR=.
##################################################
## BEGIN BKSTANDARD MAKEFILE
-include $(GROUPTOP)/Make.preinclude
include $(PKGTOP)/bkmk/Make.include
-include $(PKGTOP)/Make.include
-include $(GROUPTOP)/Make.include
-include ./Make.include
## END BKSTANDARD MAKEFILE
##################################################

BK_LOCALCLEANJUNK=.install BUILD
