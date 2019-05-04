#!/bin/bash
set -euo pipefail

usage() {
  echo 'Usage: ./sample.sh [c|haskell|java|racket]' >&2
  exit 1
}

sample_c() {
  gcc --version
  gcc -O2 -lgmp -o sum.c.elf sum.c
  time ./sum.c.elf
}

sample_haskell() {
  ghc --version
  ghc -O2 -o sum.hs.elf sum.hs
  time ./sum.hs.elf
}

sample_java() {
  java -version
  javac sum.java
  time java Sum
}

sample_racket() {
  racket --version
  time racket sum.rkt
}

sample_all() {
  sample_c
  echo
  sample_haskell
  echo
  sample_java
  echo
  sample_racket
}

if [[ $# -eq 0 ]]; then
  sample_all
elif [[ $# -ne 1 ]]; then
  usage
else
  case "$1" in
    c | haskell | java | racket) "sample_$1" ;;
    *) usage ;;
  esac
fi
