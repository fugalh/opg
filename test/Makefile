all: opts.c test

test: test.c

opts.c: opts.txt ../opg.rb
	ruby ../opg.rb $< > $@
	-rm test

.PHONY: all
