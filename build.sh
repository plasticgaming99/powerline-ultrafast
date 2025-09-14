#!/usr/bin/env sh
v . -cc clang -gc none -cflags "-O3 -march=native -flto -fno-plt -static-pie -fuse-ld=lld -Wno-implicit-function-declaration -Wno-int-conversion" -ldflags "-fuse-ld=lld -Wl,--lto-O3"
