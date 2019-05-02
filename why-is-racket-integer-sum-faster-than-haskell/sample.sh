#!/bin/bash
set -euo pipefail

gcc --version
gcc -O2 -lgmp -o sum.c.elf sum.c
time ./sum.c.elf
echo

ghc --version
ghc -O2 -o sum.hs.elf sum.hs
time ./sum.hs.elf
echo

java -version
javac sum.java
time java Sum
echo

racket --version
time racket sum.rkt
