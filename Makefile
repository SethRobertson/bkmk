
default:

# This tarball install target is fairly bogus, and doesn't really belong here,
# but until we decide on a packaging system and have something better, it will
# suffice.
install:
	@(cd ../.install; \
	  P=`pwd | bash -pc 'read P; P=\$${P%/*}; P=\$${P##*/}; echo \$$P'`; \
	  tar -zcvf ../$$P.tar.gz bin/worker bin/*.sh lib/*.so java/*.jar)

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
	./configure --disable-fast-install
	@echo "$(OSNAME)" > $(OSFILE) && touch .timestamp

.timestamp: *.in config.status
	@./config.status && touch $@

config.status: acaux/config.* acaux/ltmain.sh
