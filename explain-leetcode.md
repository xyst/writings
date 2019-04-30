# Explain LeetCode

Given:  

- a random programmer on the Internet, that's me
- some less popular puzzles on LeetCode, a competitive programming website
- a couple of minutes on each puzzle to have a workable idea
- no TAOCP at hand

This is how one programmer approaches the puzzles.

Please beware that I have neither proved nor tested them, and have omitted minor details.

To the spirit of:

![Obvious, by Abstruse Goose](https://abstrusegoose.com/230)

## Status

Ongoing.

## Tricks applied so far

- Basic data structures
- Decompose a thing into smaller things
- Do it incrementally
- Remove the trivial
- Sorting
- Try basic examples
- Try evil examples

## Caveats

- Always read the "Note" section first, size constraints can change the game.
- "eerie" is a "sub-sequence" of "exercise".

## 761. Shuffle "special" sub-strings (whose 1-count "=" 0-count, and ">=" for all prefixes)

- When can we break a "special" string into two smaller ones...
- "1100" contains "10" in the middle, but such case doesn't matter.
- "Special"-ness guarantees a unique breakdown.
- After completely broken down, we have an array, now just sort them.
- But why is the whole input "special"?

## 759. When does everyone have free time

Just interval calculation. A sorted set of pairs.

## 757. Cover two points in each interval

- Each interval is a constraint.
- If the Z3 constraint solver were supported, it'd be simple and fun...
- Trying simple examples of one, two, three intervals... Not sure if it can be done incrementally.
- How to cover one point each, instead of two? Not sure.
- We can canonicalise the intervals though, shortening the "boring" middle sections.
- What if we sort them...
- And, if an interval contains another smaller interval, we can drop the bigger one...
- Now, sorted and dropped, they are in a nice shape.
- From left to right, pick points, remove the "done" intervals, repeat.

## 753. Password forcing with a stream of input

De Brujin sequence.

(But what is the point? Not expecting people to invent a textbook algorithm within half an hour...)

## 749. Virus spreading

- Walk through the examples
- Just flood fill?

## 745. Prefix-and-suffix search

- Just prefix trees?
- Prefixes -> (suffixes -> last position)

## 736. Lisp expression

Just translate the spec into code. A simple expression evaluator.

## 732. Calendar overlap count

Just interval calculation. A sorted set of pairs, each having a count.

## 726. Count the atoms in a chemical formula

An expression evaluator.

## 716. A stack with pop-max

- Doubly linked list provides fast removal of "max" in the middle.
- Each element has an extra pointer to the previous "max".
- So push and pop are good, easy to find the max.
- However, an evil example: push from large to small, pop-max one by one.
- After pop-max, it is slow to update the extra pointers.
- Need a sorted map to look up the last position of each unique element, including the max.
- The extra pointer is to the previous equal value.

