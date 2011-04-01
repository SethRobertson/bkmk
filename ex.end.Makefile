######################################################################
#
#
# ++Copyright BAKA++
#
# Copyright © 2001-2011 The Authors. All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Send e-mail to <projectbaka@baka.org> for further information.
#
# - -Copyright BAKA- -
#
# Foo src Makefile
#
BK_SIMPLE_INTERNALPROGS=foo
BK_SIMPLE_PROGS=foo

BK_LARGE_INTERNALPROG=bar
BK_LARGE_PROG=bar
BK_LARGE_SRC=main.c init.c list.c parse.y tok.l
LOCAL_LIBS=-lbaz

BK_LARGE_INTERNALLIB=libbaz$(LIBEXT)
BK_LARGE_LIB=libbaz$(LIBEXT)
BK_LARGE_LIBSRC=alpha.c beta.c delta.c epsilon.c gamma.c

BK_PUBLIC_INC=foo.h

BK_MAN=foo.3

GROUPTOP=..
GROUPSUBDIR=src
##################################################
## BEGIN BKSTANDARD MAKEFILE
-include ./Make.preinclude
-include $(GROUPTOP)/Make.preinclude
-include $(GROUPTOP)/$(PKGTOP)/Make.preinclude
include $(GROUPTOP)/$(PKGTOP)/bkmk/Make.include
-include $(GROUPTOP)/$(PKGTOP)/Make.include
-include $(GROUPTOP)/Make.include
-include ./Make.include
## END BKSTANDARD MAKEFILE
##################################################
