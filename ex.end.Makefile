######################################################################
#
# Foo src Makefile
#
BK_SIMPLE_PROGS=foo

BK_LARGE_PROG=bar
BK_LARGE_SRC=main.c init.c list.c parse.y tok.l
LOCAL_LIBS=-lbaz

BK_LARGE_LIB=libbaz.a
BK_LARGE_LIBSRC=alpha.c beta.c delta.c epsilon.c gamma.c

GROUPTOP=..
GROUPSUBDIR=src
##################################################
## BEGIN BKSTANDARD MAKEFILE
-include $(GROUPTOP)/Make.preinclude
include $(PKGTOP)/bkmk/Make.include
-include $(PKGTOP)/Make.include
-include $(GROUPTOP)/Make.include
-include ./Make.include
## END BKSTANDARD MAKEFILE
##################################################
