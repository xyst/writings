# Why is Racket integer sum faster than Haskell

## Status

Down the rabbit hole, and not entirely correct.

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

Also a tail recursion:

~~~
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (i + s)
main = print (Main.sum 1234567890 0)
~~~

(The name "Main.sum" disambiguates with the default "sum" function.)

Compiled with `ghc -O2` (optimisation level 2), this takes 44 seconds, much slower than Racket's 6 seconds.

But Racket is interpreted!

Something is wrong...

## By the way, the setting

Racket 7.1, Glasgow Haskell Compiler (GHC) 8.0.1, Debian "Stretch" with backports, 8 GB memory, 64-bit CPU cores on a laptop.

We're talking about arbitrary-precision integers by default.

All these timings are just a few samples, not very scientific...

## Is GMP the cause?

GMP is the multi-precision arithmetic library that GHC Haskell uses for its Integer type.

`ldd` on the compiled Haskell binary lists `libgmp.so.10`, while the Racket binary (compiled by `raco exe`) doesn't. That is, the Haskell binary calls the GMP dynamic library, while Racket doesn't.

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

Compiled with `gcc -Wall -O2 -lgmp`, `ldd` reports `libgmp.so.10` just like Haskell, `time` reports 8 seconds to run.

GMP is not slow.

But Racket is faster than C here!

Mmmm...

## What about Java?

Java version: OpenJDK 11.0.3

Since Java doesn't support tail recursion, we use a "for" loop:

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

Now digging further...

## Basic Haskell profiling

We can use the Haskell Run-Time System (RTS) profiler to get some statistics.

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

So, Garbage Collection (GC) seems not the issue.

## Time to read the GHC Core

GHC Core is the "half-compiled" Haskell code. It is what we get after all optimisations on Haskell are done, but before "low-level" optimisations such as the LLVM compiler back-end.

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

"Rec" means a recursive call, and this is the only occurrence.

The code again:

~~~
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (i + s)
main = print (Main.sum 1234567890 0)
~~~

So the Core says:

- Compare "i" with "main4" (which is 0) to get a boolean
- Then match the boolean to check if finished
- Then call GMP plus and minus
- Then recursion

Some of them are slow.

## Apples and oranges

A usual thing to check is Integer versus Int. In Java we are adding a BigInteger and an "int", while in Haskell we are adding two Integer's.

Integer (and BigInteger in Java) is arbitrary-precision, while Int (and "int" in Java) is 64-bit on this machine. Integer is the mathematical integer, while Int wraps around modulo (2 ^ 64) on this machine.

To see their difference, in `ghci` interpreter:

~~~
Prelude> let a = (2 ^ 63) :: Integer in -a == a
False
Prelude> let a = (2 ^ 63) :: Int in -a == a
True
~~~

To avoid surprises like this, Haskell doesn't assume the Int type by default. (But we can ask for an Int when we find it safe.)

Since Integer is slower than Int, let's make "i" an Int like in Java.

Before:

~~~
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (i + s)
main = print (Main.sum 1234567890 0)
~~~

After:

~~~
sum :: Int -> Integer -> Integer
sum i s
  | i == 0 = s
  | otherwise = Main.sum (i - 1) (fromIntegral i + s)
main = print (Main.sum 1234567890 0)
~~~

"fromIntegral" converts Int into Integer here. (Again to avoid surprises, Haskell doesn't automatically convert between number types.)

Run:

~~~
ghc -O2 -rtsopts -ddump-simpl -o sum.hs.elf sum.hs >sum.hs.core
time ./sum.hs.elf +RTS -sstderr
~~~

20 seconds. Twice as fast!

Checking the Core:

~~~
Rec {
-- RHS size: {terms: 15, types: 3, coercions: 0}
Main.$wsum [InlPrag=[0], Occ=LoopBreaker]
  :: GHC.Prim.Int# -> Integer -> Integer
[GblId, Arity=2, Str=DmdType <S,1*U><S,U>]
Main.$wsum =
  \ (ww_s4Tm :: GHC.Prim.Int#) (w_s4Tj :: Integer) ->
    case ww_s4Tm of wild_Xo {
      __DEFAULT ->
        Main.$wsum
          (GHC.Prim.-# wild_Xo 1#)
          (integer-gmp-1.0.0.1:GHC.Integer.Type.plusInteger
             (integer-gmp-1.0.0.1:GHC.Integer.Type.smallInteger wild_Xo)
             w_s4Tj);
      0# -> w_s4Tj
    }
end Rec }
~~~

Remember the Core before:

- Compare "i" with "main4" (which is 0) to get a boolean
- Then match the boolean to check if finished
- Then call GMP plus and minus
- Then recursion

Now it says:

- Match "i" with 0 to check if finished
- Then call primitive minus, then GMP plus and "smallInteger"
- Then recursion

So, the boolean matching is gone, and the minus is on a fast primitive.

## What we have so far

- Java, 28 seconds
- Haskell, 20 seconds (using Int like in Java)
- C, 8 seconds
- Racket, 6 seconds (even without compiling)

## But why not use two Int's?

The sum 762078938126809995 is less than 64 bits. We may as well use 64-bit integers for both "i" and "s".

Then:

- Racket, 3 seconds (using "racket/fixnum" operators "fx-" and "fx+")
- Haskell, 1 second (using "Int -> Int -> Int")
- Java, 1 second (using "long" instead of "BigInteger")
- C, 0 seconds (using "unsigned long" instead of GMP library)

This is a little boring, CPUs today can add up _billions_ of integers within a second. (Though not fast enough to run Electron apps...)

Racket is a bit slower in this case. C is blazingly fast.

## What if the result exceeds 64-bit?

Let's make the result bigger by adding from 444333222111.

Racket:

~~~
#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 444333222111)
(sum begin (+ begin 1234567890) 0)
~~~

Haskell:

~~~
sum :: Int -> Int -> Integer -> Integer
sum i j s
  | i > j = s
  | otherwise = Main.sum (i + 1) j (fromIntegral i + s)
begin = 444333222111
main = print (Main.sum begin (begin + 1234567890) 0)
~~~

Java:

~~~
import java.math.BigInteger;

class Sum {
  public static void main(String[] args) {
    var s = BigInteger.valueOf(0);
    long begin = 444333222111L;
    for (long i = begin; i <= begin + 1234567890; ++i)
      s = s.add(BigInteger.valueOf(i));
    System.out.println(s);
  }
}
~~~

C:

~~~
#include <stdio.h>
#include <gmp.h>

int main(void) {
  mpz_t s;
  mpz_init(s);
  unsigned long begin = 444333222111L;
  for (unsigned long i = begin; i <= begin + 1234567890; ++i)
    mpz_add_ui(s, s, i);
  gmp_printf("%Zd\n", s);
  return 0;
}
~~~

The answers are all 549321607860938647896. The (unscientific) timings:

- Racket, 86 seconds (previously: 6 seconds)
- Haskell, 49 seconds (previously: 20 seconds)
- Java, 31 seconds (previously: 28 seconds)
- C, 7 seconds (previously: 8 seconds)

This is interesting. Only Java looks normal.

## The bytecode

Racket compiles the code into bytecode before execution. Is there a way to read the bytecode like we read the GHC Core?

Yet to find out how... But a few searches in the documentation shows we can compile into bytecode and then _decompile_ it:

~~~
raco make sum.rkt
raco decompile compiled/sum_rkt.zo
~~~

The documentation also hints that decompilation does not "de-optimise" the code.

To make them easier to compare, changed the smaller sum code so that the only difference is one line.

The smaller sum:

~~~
#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 0)
(sum begin (+ begin 1234567890) 0)
~~~

(Yes, still takes 6 seconds.)

The bigger sum:

~~~
#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 444333222111)
(sum begin (+ begin 1234567890) 0)
~~~

(Which takes 86 seconds.)

The decompiled code are both two hundred lines, and the only lines that differ are:

~~~
   (define-values (begin) '0)
   (#%apply-values print-values (sum '14 '1234567890 '91))
~~~

versus:

~~~
   (define-values (begin) '444333222111)
   (#%apply-values print-values (sum '444333222125 '445567790001 '6220665109645))
~~~

That is, the bytecode are essentially the same.

The Racket runtime somehow did a huge optimisation for the smaller sum.

## The Just-In-Time compiler

The Racket documentation provides great built-in searching. There is a section "Fixnum and Flonum Optimizations" explaining that the Just-In-Time (JIT) compiler automatically uses machine-sized integers when applicable. And JIT compiling happens during runtime.

So the JIT compiler probably "cheated" the smaller sum by using 64-bit integers instead of arbitrary-precision integers, making it faster than the C language.

To test this, turn off the JIT compiler by using `racket --no-jit sum.rkt`... Now it takes 203 seconds, instead of 6!

JIT is indeed the bread and buffer for high performance, but it does lots of things, how to know whether it avoided arbitrary-precision integers?

## The source code

Time to read the Racket source code. (Didn't expect my first Racket program to bring me here...)

Using `apt-get source` to fetch the source... In "src/racket/src" there is (their own copy of) GMP code in C language, and "jitarith.c" which does JIT compiling for integer arithmetics.

Like the documentation says, "jitarith.c" checks the integer size and sets some flags whether to use machine-sized integers.

Meanwhile "gmp.c" defines the "mpn_add_n" function that adds arbitrary-precision integers. Its real name, after "gmp.h" macro expansion, is likely "scheme_gmpn_add_n". There is also an inline function "mpn_add" which calls "mpn_add_n".

Still need more digging to understand how the two pieces work together, but for now, we have enough information to test our JIT hypothesis. Just check whether "scheme_gmpn_add_n" is called.

## The GNU debugger

The GNU debugger (GDB) lets us inspect how a C executable runs.

Launch Racket with `gdb racket`, set our breakpoint with `break scheme_gmpn_add_n` to know when the function is called, then `run sum.rkt`...

~~~
> gdb racket
...
Reading symbols from racket...(no debugging symbols found)...done.
(gdb) break scheme_gmpn_add_n
Breakpoint 1 at 0x9f7a0
(gdb) run sum.rkt
Starting program: /usr/bin/racket sum.rkt
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
(gdb)
~~~

It stops as "scheme_gmpn_add_n" gets called. Let's `continue` to see...

~~~
(gdb) continue
Continuing.

Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
(gdb) continue
Continuing.
[New Thread 0x7ffff7ff7700 (LWP 18455)]

Thread 1 "sum.rkt" received signal SIGSEGV, Segmentation fault.
0x00005555555fba1a in scheme_gmp_tls_unload ()
(gdb) 
~~~

Oops. "scheme_gmpn_add_n" is called another time, and then... A segmentation fault? Usually it means that the C code has a memory corruption bug and has crashed. But it did run fine without the debugger! Why?

## Heisenbug and the garbage collector

Strangers on the Internet suggest a few causes. One is the well-known Heisenbug, that is the debugger affects how the program runs. Especially common for multithreaded programs and timers.

Another cause is that some garbage collectors make creative use of segmentation faults to manage memory... Maybe Racket too? In this case, it is recommended to set `handle SIGSEGV nostop noprint` in the debugger.

## Back to the debugger

Putting things together, we can write a shell script to avoid timing problems and ignore segmentation faults.

~~~
#!/bin/bash
set -euo pipefail
gdb racket <<EOF
handle SIGSEGV nostop noprint
break scheme_gmpn_add_n
command 1
  print 123
  continue
end
run sum.rkt
EOF
~~~

The few lines after "command 1" means: when Breakpoint 1 (the only breakpoint) is reached, print something arbitrary (123), and continue to run.

Let's try it on the smaller sum:

~~~
#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 0)
(sum begin (+ begin 1234567890) 0)
~~~

The result:

~~~
> ./run-with-debugger.sh 
...
Reading symbols from racket...(no debugging symbols found)...done.
(gdb) Signal        Stop  Print Pass to program Description
SIGSEGV       No  No  Yes   Segmentation fault
(gdb) Breakpoint 1 at 0x9f7a0
(gdb) >>>(gdb) Starting program: /usr/bin/racket sum.rkt
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$1 = 123

Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$2 = 123
[New Thread 0x7ffff7ff7700 (LWP 19526)]
762078938126809995
[Thread 0x7ffff7ff7700 (LWP 19526) exited]
[Inferior 1 (process 19522) exited normally]
(gdb) quit
~~~

Yes! "scheme_gmpn_add_n" is only called twice.

What about the bigger sum:

~~~
#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 444333222111)
(sum begin (+ begin 1234567890) 0)
~~~

Lots and lots of printing... My estimation is that it'll take a month to finish.

Changing the code to use a larger "begin" and fewer numbers:

~~~
#lang racket/base
(define (sum i j s)
  (if (> i j) s (sum (+ i 1) j (+ i s))) )
(define begin 666555444333222111)
(sum begin (+ begin 1234) 0)
~~~

The result:

~~~
> time ./run-with-debugger.sh 
...
Reading symbols from racket...(no debugging symbols found)...done.
(gdb) Signal        Stop  Print Pass to program Description
SIGSEGV       No  No  Yes   Segmentation fault
(gdb) Breakpoint 1 at 0x9f7a0
(gdb) >>>(gdb) Starting program: /usr/bin/racket sum.rkt
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$1 = 123

Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$2 = 123
[New Thread 0x7ffff7ff7700 (LWP 20741)]

Thread 1 "sum.rkt" hit Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$3 = 123

...

Thread 1 "sum.rkt" hit Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$1229 = 123

Thread 1 "sum.rkt" hit Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$1230 = 123

Thread 1 "sum.rkt" hit Breakpoint 1, 0x00005555555f37a0 in scheme_gmpn_add_n ()
$1231 = 123
823195973751530069080
[Thread 0x7ffff7ff7700 (LWP 20741) exited]
[Inferior 1 (process 20737) exited normally]
(gdb) quit
~~~

"scheme_gmpn_add_n" is called 1231 times.

The Racket runtime does avoid arbitrary-precision arithmetics when the numbers are small.

## Answering the original question

Racket is faster than Haskell when adding up a billion numbers (which are under half a trillion), this is because the Just-In-Time compiler automatically uses machine-sized integer when applicable, which is much faster than using arbitrary-precision integers.

Among Racket, Haskell, Java, and C, this seems unique to Racket.

In Haskell/Java/C, we can choose _either_ 64-bit integers _or_ arbitrary-precision integers, that is, either be fast or be safe. When the choice changes, the code has to change.

In Racket, it is the same code for _both_. The runtime makes the choice. In this way, Racket makes simple code run fast in the usual case, while staying safe in other cases.

And, of course, there is a price to pay. For example, machine-sized integers in Racket is less than 64 bits on 64-bit machines. In the Haskell website, there are also a few relevant discussions on the GMP library and the trade-offs of "small integers".

Now to the other findings...

## Next

