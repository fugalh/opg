all: opts.c test

test: test.c

opts.c: opts.txt ../opg
	ruby ../opg $< > $@
	-rm test

.PHONY: all
