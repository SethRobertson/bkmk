# -*- makefile -*-
#
# $Id: Make.GNUmakefile,v 1.1 2002/01/18 18:45:40 dupuy Exp $
#
# ++Copyright LIBBK++
#
# Copyright (c) 2001,2002 The Authors.  All rights reserved.
#
# This source code is licensed to you under the terms of the file
# LICENSE.TXT in this release for further details.
#
# Mail <projectbaka@baka.org> for further information
#
# --Copyright LIBBK--
#
# Common elements for use in GNUmakefile bkmk adaptors for software
# built in $(ARCH) subdirectories using autoconf-generated configure scripts
#
ARCH:=$(shell sh ./config.guess)
CONFIGURED:=$(ARCH)/config.status

include $(BKMKDIR)/Make.bkvariables
-include $(BKMKDIR)/Make.$(BK_OSNAME)-pre
include $(BKMKDIR)/Make.config
-include $(BKMKDIR)/Make.$(BK_OSNAME)-post

DEFAULT: $(CONFIGURED)
	cd $(ARCH) && $(MAKE)

include $(PKGTOP)/Make.include

install: $(CONFIGURED)
	-mkdir -p $(INSTBASE)
	cd $(ARCH) && $(MAKE) && $(MAKE) $@

subtags: tags
neat: clean
nuke: distclean

clean:
	@if test -f $(ARCH)/Makefile && cd $(ARCH); then $(MAKE) $@; fi

distclean:
	-@if test -f $(ARCH)/Makefile; then $(MAKE) -f $(ARCH)/Makefile $@; fi
	$(RM_CONFIG) -rf $(ARCH)

.DEFAULT: $(CONFIGURED)
	cd $(ARCH) && $(MAKE) $@
