# -*- makefile -*-
#
# $Id: Make.GNUmakefile,v 1.33 2005/02/07 18:45:06 seth Exp $
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

include $(PKGTOP)/Make.preinclude

GUESS=for D in . config;					\
 do test -f $$D/config.guess && { sh $$D/config.guess; exit; };	\
 done 2>/dev/null;						\
 echo build
ARCH:=$(shell $(GUESS))
ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
CONFIGURED:=$(ARCH)/config.status
else
CONFIGURED:=config.status
endif

include $(BKMKDIR)/Make.bkvariables
-include $(BKMKDIR)/Make.$(BK_OSNAME)-pre
include $(BKMKDIR)/Make.config
include $(BKMKDIR)/Make.override
include $(BKMKDIR)/Make.variables
-include $(BKMKDIR)/Make.$(BK_OSNAME)-post

# make INSTBASE normalized absolute path
BK_GETCWD= . $(BKMKDIR)/getcwd.sh 2>/dev/null || . $(BKMKDIR)/getcwd.sh.in

# BKMK_INSTALL_SUBDIR is intended for use by third party distributions which you want
# to install beneath $(INSTALLBASE) but in their own private subtree.
INSTALLBASE:=$(shell $(BK_GETCWD); pawd $(BK_INSTALLBASE)/$(BKMK_INSTALL_SUBDIR))

NORMALIZEBASE='$$_ = q^$(PWD)/$(INSTALLBASE)^;'$(NORMALIZE)
INSTBASE:=$(shell $(PERL) -e $(NORMALIZEBASE))
export INSTBASE

DEFAULT: $(CONFIGURED)
ifneq ($(strip $(BK_WANT_C)),false)
ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
	cd $(ARCH) && $(MAKE)
else
	$(MAKE) -f Makefile
endif
else
	@:
endif

include $(PKGTOP)/Make.include

install-normal install-last:

install-first actual_install:: install

install:: $(CONFIGURED)
	-$(MKDIR_CONFIG) -p $(INSTBASE)
ifneq ($(strip $(BK_WANT_C)),false)
ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
	cd $(ARCH) && $(MAKE) && $(MAKE) $@
else
	$(MAKE) -f Makefile $@
endif
endif

subtags: tags
neat: clean

ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
clean nuke: distclean distclean-generic
	$(RM_CONFIG) -rf $(ARCH)

clean::
	@if test -f $(ARCH)/Makefile && cd $(ARCH); then $(MAKE) $@; fi

else
clean nuke: distclean
endif

distclean distclean-generic distclean-am::
	-@test -f $(ARCH)/Makefile && $(MAKE) -k -f $(ARCH)/Makefile $@ \
	  || test -f Makefile && $(MAKE) -k -f Makefile $@

ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
CONFIGCMD=cd $(ARCH) && ../configure --prefix=$$INSTBASE $(CACHE_FILE) $(CONFIGOPTS) 
ifneq ($(WANT_CONFIG_CACHE),false)
CACHE_FILE=--cache-file=../$(BKMKDIR)/config.cache
endif
else
CONFIGCMD=./configure --prefix=$$INSTBASE $(CACHE_FILE) $(CONFIGOPTS)
ifneq ($(WANT_CONFIG_CACHE),false)
CACHE_FILE=--cache-file=$(BKMKDIR)/config.cache
endif
endif

$(CONFIGURED):: configure
ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
	-@$(MKDIR_CONFIG) -p $(ARCH)
endif
	@case $(ARCH) in						      \
	 *openbsd*)							      \
	   CPPFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib";	      \
	   export CPPFLAGS LDFLAGS ;;					      \
	esac;								      \
	if $(GREP) -s '\$$(DESTDIR)' Makefile.in > /dev/null 2>&1; then	      \
	  case $$INSTBASE in						      \
	    /*/usr/*)							      \
	      eval `echo $$INSTBASE					      \
		    | $(SED) 's@\(/.*\)\(/usr/.*\)@DESTDIR=\1 INSTBASE=\2@'`; \
	      ;;							      \
	    /*/opt/*)							      \
	      eval `echo $$INSTBASE					      \
		    | $(SED) 's@\(/.*\)\(/opt/.*\)@DESTDIR=\1 INSTBASE=\2@'`; \
	      ;;							      \
	    '') INSTBASE='$(INSTBASE)' ;;				      \
	  esac;								      \
	fi;								      \
	$(CONFIGCMD) &&							      \
	if [ -n "$$DESTDIR" ]; then					      \
	  echo DESTDIR=$$DESTDIR					      \
	   | $(TEE) -a `$(FIND) . -name Makefile -print` >/dev/null;	      \
	fi
ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
	-@$(MAKE) -f $(ARCH)/Makefile clean 2>/dev/null
endif

.DEFAULT: $(CONFIGURED)
ifneq ($(strip $(BK_WANT_C)),false)
ifneq ($(strip $(WANT_SUBDIRBUILD)),false)
	$(MAKE) -C $(ARCH) $@
else
	$(MAKE) -f Makefile $@
endif
else
	@:
endif

# targets to avoid complaints about missing make includes
$(BKMKDIR)/Make.$(BK_OSNAME)-pre:
$(BKMKDIR)/Make.$(BK_OSNAME)-post:
$(GROUPTOP)/$(PKGTOP)/.user-variables:

