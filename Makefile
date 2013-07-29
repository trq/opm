PREFIX=/usr/local

EXEC_FILES=bin/opm

LIB_FILES=usr/lib/opm/bootstrap.sh
LIB_FILES+=usr/lib/opm/lib.sh
LIB_FILES+=usr/lib/opm/main.sh
LIB_FILES+=usr/lib/opm/stage.sh
LIB_FILES+=usr/lib/opm/usage.sh
LIB_FILES+=usr/lib/opm/util.sh

CONF_FILES=etc/opm.conf-dist

MAN_FILES=usr/share/man/man8/opm.1.gz

all:
	@echo "usage: make install"
	@echo "       make uninstall"

install:
	install -d -m 0755 $(PREFIX)/bin
	install -d -m 0755 $(PREFIX)/lib/opm
	install -d -m 0755 $(PREFIX)/etc
	install -d -m 0755 $(PREFIX)/share/man/man8

	install -m 0755 $(EXEC_FILES) $(PREFIX)/bin
	install -m 0644 $(LIB_FILES) $(PREFIX)/lib/opm
	install -m 0644 $(CONF_FILES) $(PREFIX)/etc/opm.conf
	install -m 0644 $(MAN_FILES) $(PREFIX)/share/man/man8

uninstall:
	test -d $(PREFIX)/bin && \
	cd $(PREFIX)/bin && \
	rm -f $(EXEC_FILES) $(SCRIPT_FILES)

	test -d $(PREFIX)/lib/opm && \
	cd $(PREFIX)/bin && \
	rm -fr $(PREFIX)/lib/opm
