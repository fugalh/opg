PREFIX=/usr/local/bin
all:
	@echo "targets: test, install, uninstall"
test:
	make -C test

install:
	install -d $(PREFIX)
	install -t $(PREFIX) opg

uninstall:
	rm -f $(PREFIX)/opg

.PHONY: test
