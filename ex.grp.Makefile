######################################################################
# $Id: ex.grp.Makefile,v 1.2 2001/06/18 19:29:32 seth Exp $
#
# Foo group Makefile 
#
BK_SUBDIR=lib src include

GROUPTOP=.
GROUPSUBDIR=.
##################################################
## BEGIN BKSTANDARD MAKEFILE
-include $(GROUPTOP)/Make.preinclude
include $(PKGTOP)/bkmk/Make.include
-include $(PKGTOP)/Make.include
-include $(GROUPTOP)/Make.include
-include ./Make.include
## END BKSTANDARD MAKEFILE
##################################################
