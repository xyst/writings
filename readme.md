# Why is Racket integer sum faster than Haskell

## Status

Unfinished, and not entirely correct.

## The story

When playing with a new language, I like to see how many integers it can add up within a few seconds.

In Racket, a dynamic language with tail recursion, it is a few lines:

~~~
#lang racket/base
(define (sum i s)
  (if (zero? i) s (sum (- i 1) (+ i s))) )
(sum 1234567890 0)
~~~

The answer is 762078938126809995. `time racket sum.rkt` says 6 seconds.

That's... fast! 

## Haskell by comparison

Also tail recursion:

~~~
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (fromIntegral i + s)
main = print (Main.sum 1234567890 0)
~~~

(The name "Main.sum" disambiguates with the default "sum" function.)

Compiled with `ghc -O2`, this takes 44 seconds, much slower than Racket's 6 seconds.

But Racket is interpreted! Something is wrong...

## By the way, the setting

Racket 7.1, Glasgow Haskell Compiler (GHC) 8.0.1, Debian "Stretch" with backports, 8 GB memory, 64-bit CPU cores on a laptop.

We're talking about arbitrary-precision integers by default.

All these timings are just a few samples, not very scientific...

## Is GMP the cause?

GMP is the multi-precision arithmetic library that GHC Haskell uses for its Integer type.
`ldd` the compiled Haskell binary lists `libgmp.so.10`, while the Racket binary (compiled by `raco exe`) doesn't.

To test GMP without Haskell, we can use a C program:

~~~
#include <stdio.h>
#include <gmp.h>

int main(void) {
  mpz_t s;
  mpz_init(s);
  for (unsigned long i = 1; i <= 1234567890; ++i)
    mpz_add_ui(s, s, i);
  gmp_printf("%Zd\n", s);
  return 0;
}
~~~

GMP version: libgmp10 2:6.1.2+dfsg-1 (no idea what it means)  
GCC version: 6.3.0

Compiled with `gcc -O2 -lgmp`, `ldd` reports `libgmp.so.10` just like Haskell, `time` reports 8 seconds to run.

GMP is not slow.

But Racket is faster than C in this case!

Mmmm...

## What about Java?

Java version: OpenJDK 11.0.3

~~~
import java.math.BigInteger;

class Sum {
  public static void main(String[] args) {
    var s = BigInteger.valueOf(0);
    for (int i = 1; i <= 1234567890; ++i)
      s = s.add(BigInteger.valueOf(i));
    System.out.println(s);
  }
}
~~~

Compiled with `javac`, it takes 28 seconds to run. Faster than Haskell's 44 seconds.

Also, `strace java Sum` doesn't show "libgmp", so OpenJDK Java doesn't use the GMP library.

## So far, we have

- Haskell, 44 seconds
- Java, 28 seconds
- C, 8 seconds
- Racket, 6 seconds (even without compiling)

## Basic Haskell profiling

Using the built-in RTS profiler...

Compile:

~~~
ghc -O2 -rtsopts -o sum.hs.elf sum.hs
~~~

Run:

~~~
./sum.hs.elf +RTS -sstderr
~~~

See:

~~~
  59,259,310,536 bytes allocated in the heap
       4,233,528 bytes copied during GC
...
  INIT    time    0.000s  (  0.000s elapsed)
  MUT     time   44.423s  ( 44.435s elapsed)
  GC      time    0.339s  (  0.328s elapsed)
  EXIT    time    0.000s  (  0.000s elapsed)
  Total   time   44.764s  ( 44.763s elapsed)

  %GC     time       0.8%  (0.7% elapsed)
...
~~~

The time numbers match those reported by the `time` command.

Garbage collection (GC) seems not the issue.

## Time to read the GHC Core

GHC Core is the "half-compiled" Haskell code. It is what we get after all optimisations on Haskell are done, but before "low-level" optimisations such as the LLVM compiler backend.

To dump the Core:

~~~
ghc -O2 -ddump-simpl sum.hs
~~~

The output is over a hundred lines, will take a while to comprehend, but the relevant calculation might be:

~~~
Rec {
-- RHS size: {terms: 20, types: 5, coercions: 0}
Main.main_sum [Occ=LoopBreaker] :: Integer -> Integer -> Integer
[GblId, Arity=2, Str=DmdType <S,U><S,U>]
Main.main_sum =
  \ (i_aqs :: Integer) (s_aqt :: Integer) ->
    case integer-gmp-1.0.0.1:GHC.Integer.Type.eqInteger#
           i_aqs Main.main4
    of wild_a2At { __DEFAULT ->
    case GHC.Prim.tagToEnum# @ Bool wild_a2At of _ [Occ=Dead] {
      False ->
        Main.main_sum
          (integer-gmp-1.0.0.1:GHC.Integer.Type.minusInteger i_aqs lvl_r52K)
          (integer-gmp-1.0.0.1:GHC.Integer.Type.plusInteger i_aqs s_aqt);
      True -> s_aqt
    }
    }
end Rec }
~~~

"Rec" means a recursive call, and this is the only place.

The code again:

~~~
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (fromIntegral i + s)
main = print (Main.sum 1234567890 0)
~~~

So the Core says, first compare with "main4" (which is 0) and get a boolean, then match the boolean, then call GMP plus and minus, then recursion.

## Next

