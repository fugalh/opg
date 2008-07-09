#! /bin/sh -x
make && {
./test
./test -h
./test -f | grep ^f
./test -b hello | grep ^b
./test -z | grep ^z
./test -z42 | grep ^z
./test --baz=42 | grep ^z
./test -q 3.14159265358979 | grep ^q
}
