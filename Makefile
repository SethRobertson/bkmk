
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

clean nuke:
	rm -f .config_os_type confdefs.h config.cache config.status config.log libbk_autoconf.h

%.status: ./%ure
	./configure
	@echo "$(OSNAME)" > $(OSFILE) && touch .timestamp

.timestamp: *.in config.status
	@./config.status && touch $@

config.status: acaux/config.* acaux/ltmain.sh
