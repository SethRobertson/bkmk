######################################################################
# $Id: ex.pkg.Makefile,v 1.7 2002/07/16 19:37:29 dupuy Exp $
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
# Foo package meta Makefile 
#
BK_SUBDIR=libclc glib libbk bkmk

GROUPTOP=.
GROUPSUBDIR=.
PKGTOP=.
PKGSUBDIR=.
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

BK_LOCALCLEANJUNK=$(BK_INSTALLBASE) $(BK_JAVADIR) BUILD
