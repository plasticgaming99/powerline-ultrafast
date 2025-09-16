#!/usr/bin/env sh
v . -cc clang -gc none -d no_segfault_handler -cflags "-O3 -march=native -flto -fno-plt -static-pie -fuse-ld=lld -fno-stack-protector -faddrsig -fforce-emit-vtables -fwhole-program-vtables -Wno-implicit-function-declaration -Wno-int-conversion -ffunction-sections -fdata-sections" -ldflags "-fuse-ld=lld -Wl,--lto-O3,--gc-sections,--icf=all"

if [ -f /usr/bin/llvm-strip ]; then
  llvm-strip --discard-all powerline-ultrafast
else
  strip --discard-all powerline-ultrafast
fi
