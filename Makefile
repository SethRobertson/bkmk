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
	@echo "No default target here - valid targets: autoconf clean nuke"
	@echo "You probably want to run make in the parent directory"
else
%:
	@ :
endif
#
################################################################

autoconf:
	/usr/local/bin/autoconf -Wall

clean nuke:
	rm -f $(OSFILE) confdefs.h config.cache config.status config.log \
	 libbk_autoconf.h .timestamp

%.status: ./%ure
	./configure --disable-fast-install
	echo "$(OSNAME)" > $(OSFILE) && : > .timestamp

.timestamp: *.in config.status
	@./config.status && : > $@

config.status: acaux/config.* acaux/ltmain.sh


.PHONY: default autoconf clean nuke
