CFLAGS+=-ansi -pedantic
all: clean opts test
	./test.sh

test: opts.c test.c opts.h

opts: opts.txt ../opg
	../opg $<

clean:
	rm -f test *.o opts.[hc]

.PHONY: all clean
