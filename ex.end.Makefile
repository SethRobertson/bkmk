######################################################################
# $Id: ex.end.Makefile,v 1.3 2001/06/18 20:09:50 seth Exp $
#
# ++Copyright LIBBK++
#
# Copyright (c) 2001 The Authors.  All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Mail <projectbaka@baka.org> for further information
#
# --Copyright LIBBK--
#
# Foo src Makefile
#
BK_SIMPLE_PROGS=foo

BK_LARGE_PROG=bar
BK_LARGE_SRC=main.c init.c list.c parse.y tok.l
LOCAL_LIBS=-lbaz

BK_LARGE_LIB=libbaz.a
BK_LARGE_LIBSRC=alpha.c beta.c delta.c epsilon.c gamma.c

BK_PUBLIC_INC=foo.h

GROUPTOP=..
GROUPSUBDIR=src
##################################################
## BEGIN BKSTANDARD MAKEFILE
-include $(GROUPTOP)/Make.preinclude
include $(GROUPTOP)/$(PKGTOP)/bkmk/Make.include
-include $(GROUPTOP)/$(PKGTOP)/Make.include
-include $(GROUPTOP)/Make.include
-include ./Make.include
## END BKSTANDARD MAKEFILE
##################################################
