# 
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
OSNAME = $(shell uname -s | tr / - | sed 's/_.*//')-$(shell uname -r | sed 's/\(\.[^.()-]*\)[-.].*/\1/')-$(shell uname -m | tr / - )

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
	autoconf -Wcross -Wsyntax

clean:
	rm -f $(OSFILE) confdefs.h config.cache config.status config.log \
	 $(filter-out Make%,$(GENFILES)) libtool .timestamp

ifeq ($(strip $(MAKECMDGOALS)),)
MAKECMDGOALS:=default
endif

ifeq ($(strip $(BK_CMDGOALS)),)
BK_CMDGOALS:=$(MAKECMDGOALS)
endif

nuke: clean
ifeq ($(word $(words $(MAKECMDGOALS)),$(MAKECMDGOALS)),nuke)
ifeq ($(word $(words $(BK_CMDGOALS)),$(BK_CMDGOALS)),nuke)
	  rm -f $(filter Make%,$(GENFILES))
endif
endif

-include ../.user-variables

ifeq ($(BK_BUILD_32BIT_ON_64),true)
CC = gcc -m32
CXX = g++ -m32
export CC CXX
endif # BK_BUILD_32BIT_ON_64


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
