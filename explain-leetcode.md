# Explain LeetCode

How a random programmer on the Internet approaches the less popular puzzles on LeetCode, a competitive programming website.

- Pretending that the purpose is to get a workable idea within a couple of minutes, not to memorise TAOCP.
- Please beware that I haven't tested them, and have omitted minor details.

## Status

Ongoing.

## Tricks applied so far

- Basic data structures
- Decompose a thing into smaller things
- Do it incrementally
- Remove the trivial
- Sorting
- Try simple examples

## 761. Shuffle "special" sub-strings (whose 1-count "=" 0-count, and ">=" for all prefixes)

- When can we break a "special" string into two smaller ones...
- "1100" contains "10" in the middle, but such case doesn't matter.
- "Special"-ness guarantees a unique breakdown.
- After completely broken down, we have an array, now just sort them.
- But why is the whole input "special"?

## 759. When does everyone have free time

Just interval calculation. A set of pairs.

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
- Prefixes -> (suffixes -> index)

