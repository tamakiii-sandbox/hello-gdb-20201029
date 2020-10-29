.PHONY: help setup dependencies clean
.PHONY: build codesign kill-taskgated run info

help:
	@cat $(firstword $(MAKEFILE_LIST))

setup: \
	dependencies \
	check \
	info

dependencies:
	@type gcc > /dev/null
	@type gdb > /dev/null
	@type csrutil > /dev/null
	@type codesign > /dev/null

check: ~/.gdbinit
	grep -q 'set startup-with-shell off' $< || \
		{ echo "add 'set startup-with-shell off' to $<"; exit $$?; }
	@echo "$< is OK"

build: \
	a.out

codesign: gdb.xml
	codesign --entitlements $< -fs gdb $(shell which gdb)

kill-taskgated:
	sudo pkill taskgated

run: a.out
	gdb a.out

info:
	gcc --version
	@echo
	gdb --version
	@echo
	csrutil status
	@echo
	codesign -vv $(shell which gdb)

a.out: bubblesort.c
	gcc -g -O0 $<

clean:
	rm -rf a.out
	rm -rf a.out.dSYM
