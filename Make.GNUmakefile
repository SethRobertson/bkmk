# -*- makefile -*-
#
# $Id: Make.GNUmakefile,v 1.14 2003/06/17 05:59:47 seth Exp $
#
# ++Copyright LIBBK++
#
# Copyright (c) 2003 The Authors. All rights reserved.
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
ARCH:=$(shell if [ -f ./config.guess ]; then sh ./config.guess; else echo build; fi 2>/dev/null)
CONFIGURED:=$(ARCH)/config.status

-include $(GROUPTOP)/$(PKGTOP)/.user-variables

include $(BKMKDIR)/Make.bkvariables
-include $(BKMKDIR)/Make.$(BK_OSNAME)-pre
include $(BKMKDIR)/Make.config
-include $(BKMKDIR)/Make.$(BK_OSNAME)-post

DEFAULT: $(CONFIGURED)
ifneq ($(strip $(BK_WANT_C)),false)
	cd $(ARCH) && $(MAKE)
else
	@:
endif

include $(PKGTOP)/Make.include

install-first install-normal actual_install install-last:: install

install:: $(CONFIGURED)
	-mkdir -p $(INSTBASE)
ifneq ($(strip $(BK_WANT_C)),false)
	cd $(ARCH) && $(MAKE) && $(MAKE) $@
endif

subtags: tags
neat: clean
nuke: distclean

clean::
	@if test -f $(ARCH)/Makefile && cd $(ARCH); then $(MAKE) $@; fi

distclean::
	-@if test -f $(ARCH)/Makefile; then $(MAKE) -f $(ARCH)/Makefile $@; fi
	$(RM_CONFIG) -rf $(ARCH)

.DEFAULT: $(CONFIGURED)
ifneq ($(strip $(BK_WANT_C)),false)
	cd $(ARCH) && $(MAKE) $@
else
	@:
endif

# targets to avoid complaints about missing make includes
$(BKMKDIR)/Make.$(BK_OSNAME)-pre:
$(BKMKDIR)/Make.$(BK_OSNAME)-post:
$(GROUPTOP)/$(PKGTOP)/.user-variables:

