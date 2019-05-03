# A Haskeller learns Racket

After being a Haskell beginner for a decade, I discovered Racket.

## Status

Beginning.

## First sight of Racket

It can draw the Sierpinsky triangle!

## First glance at the documentation

Out of the box, it has:

- 3-dimensional plotting
- Graphical user interfaces (GUI)
- Logic programming
- Datalog, logic programming meets the database
- Literate programming
- Games, and turtle graphics
- Type system, lazy evaluation, concurrency, contracts, modules, compiler, profiler, unit test, packages, web development
- 2-dimensional syntax!

So it is the most fun to have since QBasic? Yay!

## First week diving in

### Read, read

The tutorials are well-done.

### Missing from the manual

What are the "[ ]" brackets?  
(Explained somewhere: same as "( )", used by convention.) 

What is in "racket/base"?

How to write an optional value? "Maybe"? "#f"? "(void)"?  
(Using "#f" seems to be the convention.)

### (()(())(()(())))

Time to write some code...

Parentheses are cluttering! But after a few days they feel OK.

__Sweet Expressions__ avoid most parentheses, and are easier to read.

However, when editing Sweet Expressions, error messages can get difficult. There are also a few edge cases such as needing a line of one semicolon. It's not Haskell's layout rule.

Since Vim "%" movement works well, sticking with the noisy parentheses instead.

A bigger problem is, they are hard to type on a keyboard.

An imperfect solution for now: Emacs with Evil (Vim emulation) and Paredit (auto closing parentheses). Rainbow Delimiters (colouring) doesn't help for me...

Wait, one more takeaway:

A simplistic syntax is a _plus_ when learning new languages. You get to the semantics directly! (Can't count the times I struggled to make sense of new syntaxes...)

### More impressions

Integer sum is so fast! [How can that be?](why-is-racket-integer-sum-faster-than-haskell/readme.md)

In general, Haskell is uniform and clean. Racket (or maybe LISP) has many twisty little passages, all alike... It is enlightening to shift between the two.

## By the way, open sesame

If you get comfortable with parentheses, new possibilities are open:

- Guix, an immutable Linux distribution
- Jepsen, to test distributed systems
- Z3, a useful constraint solver
- Emacs, to play with its plugins
- Canonical S-expression, a simple way to serialise data

## Next
