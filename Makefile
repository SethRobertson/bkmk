# $Id: Makefile,v 1.27 2003/10/28 00:39:44 dupuy Exp $
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
#
OSFILE=.config_os_type
OSNAME = $(shell uname -s | tr / - | sed 's/_.*//')-$(shell uname -r | sed 's/\(\.[^.()-]*\)[-.].*/\1/')

SRCFILES:=$(subst configure.in,,$(wildcard *.in))
GENFILES=$(subst .in,,$(SRCFILES))


default:
################################################################
#
# Print an error message if someone tries to run a toplevel make
# in this directory. Otherwise just do nothing
#
ifeq ($(MAKELEVEL),0)
%:
	@echo "No default target here - valid targets: autoconf clean nuke"
	@echo "You probably want to run make in the parent directory"
else
%:
	@ :
endif
#
################################################################

autoconf:
	/usr/local/bin/autoconf -Wcross -Wsyntax

clean:
	rm -f $(OSFILE) confdefs.h config.cache config.status config.log \
	 $(filter-out Make%,$(GENFILES)) libtool .timestamp

ifeq ($(BK_CMDGOALS),)
BK_CMDGOALS:=$(MAKECMDGOALS)
endif

nuke: clean
ifeq ($(word $(words $(MAKECMDGOALS)),$(MAKECMDGOALS)),nuke)
ifeq ($(word $(words $(BK_CMDGOALS)),$(BK_CMDGOALS)),nuke)
	  rm -f $(filter Make%,$(GENFILES))
endif
endif

%.status: ./%ure
	./configure --config-cache $(CONFIGURE_ARGS)
	@-chmod +x $(filter %.sh %.pl,$(GENFILES))
	echo "$(OSNAME)" > $(OSFILE) && : > .timestamp

# <TRICKY>In order for this rule to run once, regardless of the number of out
# of date configure-generated files, we use a phony pattern with % stem of '.';
# requiring each generated file to contain exactly one . in its name.</TRICKY>
GENPAT=$(subst .,%,$(GENFILES))
$(GENPAT) %timestamp: $(addsuffix .in,$(GENPAT)) config%status
	@./config.status && : > .timestamp
	@-chmod +x $(filter %.sh %.pl,$(GENFILES))


config.status: acaux/config.* acaux/ltmain.sh


.PHONY: default autoconf clean nuke
