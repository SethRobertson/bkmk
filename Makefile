OSFILE=.config_os_type
OSNAME = $(shell uname -s | tr / - | sed 's/_.*//')-$(shell uname -r | sed 's/\(\.[^.()-]*\)[-.].*/\1/')



default:

################################################################
#
# Print an error message if someone tries to run a toplevel make
# in this directory. Otherwise just do nothing
#
ifeq ($(MAKELEVEL),0)

%:
	@echo This Makefile only has target "clean" to get rid of configure cruft.  This package is used by other packages only.  Go elsewhere.

else

%:
	@ $(TRUE)
endif
#
################################################################

autoconf:
	/usr/local/bin/autoconf -Wall

clean nuke:
	rm -f .config_os_type confdefs.h config.cache config.status config.log libbk_autoconf.h .timestamp

%.status: ./%ure
	./configure --disable-fast-install
	echo "$(OSNAME)" > $(OSFILE) && touch .timestamp

.timestamp: *.in config.status
	@./config.status && touch $@

config.status: acaux/config.* acaux/ltmain.sh

.PHONY: default autoconf clean nuke
