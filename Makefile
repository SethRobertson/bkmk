
default %:
	@echo This Makefile only has target "clean" to get rid of configure cruft.  This package is used by other packages only.  Go elsewhere.

clean nuke neat:
	rm -f .config_os_type confdefs.h config.cache config.status config.log Make.config
