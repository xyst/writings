# Explain LeetCode

Given:  

- A random programmer on the Internet, that's me
- Some less popular puzzles on LeetCode, a competitive programming website
- A couple of minutes on each puzzle to have a workable idea
- No TAOCP tome at hand

This is how one programmer approaches the puzzles.

Please beware that I have neither proved nor tested them, and have omitted minor details.

In the spirit of: [Obvious, by Abstruse Goose](https://abstrusegoose.com/230)

## Status

Ongoing.

## Trophies

- Basic data structures
- Decompose a thing into smaller things
- Do it incrementally
- Induction, build on top of a lesser problem
- Remove the trivial
- Sorting
- Try basic examples
- Try evil examples
- Work backwards

## Caveats

- Always read the "Note" section, size constraints can change the game.
- "eerie" is a "subsequence" of "exercise".

## 761. Shuffle "special" substrings (whose 1-count "=" 0-count, and ">=" for all prefixes)

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

## 727. Subsequence with the shortest span

- Build an index for each letter.
- Search letter by letter using the index.
- A shortcut: when looking for the target "ab...", skip "axxayyb" ahead to "ayyb".
- But this doesn't accumulate, working from target "ab..." to target "abc..." will need backtracking.
- So we should search in reverse instead, finding the nearest previous letter one by one.
- No, searching in reverse has exactly the same problem.
- So, go forward finding the first occurrence letter by letter, then, start from the last found letter, search letter by letter in reverse; that is a local minimum span.
- Move forward by 1 letter.
- Repeat, forward-then-backward each time.

## 726. Count the atoms in a chemical formula

An expression evaluator.

## 716. A stack that supports pop-max

- Doubly linked list, so that it is fast to remove "max" in the middle.
- Each element has an extra pointer to the previous "max".
- Then "push" and "pop" are good, also easy to find the max.
- However, an evil example: push from large to small, pop-max one by one.
- After pop-max, it is slow to update all the extra pointers.
- Need a sorted map to look up the last position of each unique element, including the max.
- The extra pointer points to the previous equal value instead.

## 715. Interval arithmetic

A sorted set of pairs.

## 711. Count the different shapes of connected pieces

- Walk through the examples.
- Flood fill, cut out each piece and put it into a bounding box full of 0s.
- Canonicalise by reading each piece-inside-bounding-box in all 8 ways, and select the smallest bit string.
- Speedup: firstly, categorise by the bounding box shape, and then the 1-count.
- Speedup: then, only if a category contains multiple pieces, canonicalise them and sort.

## 699. Height of square Tetris

- Build a histogram.
- Interval calculation. Sorted set of pairs, each having a height.

## 689. Max sum of 3 sections of the same length, non-overlapping

- Unspecified, but the example indicates that a "subarray" is a consecutive section, unlike a "subsequence".
- Run through the input once, calculate the value of each length-k section.
- Sections of high values can overlap; sort the sections by value first?
- Can't tell how to use the sorted sections effectively.
- Induction? If we have the answer for "max sum of 1 section..." for all prefix ranges, we can answer "max sum of 2 sections..." for all prefix ranges?
- Yes.

## 685. Directed tree with an extra edge, find and remove that edge

- Walk through the examples.
- Must not create two roots. The root will have no parent, other nodes each have 1 parent.
- Work backwards, add an edge to a directed tree.
- The added edge points to either the root or a child node. Always creating 1 undirected loop.
- Find the undirected loop? Not easy.
- If the added edge points to a child node, there will be 1 node with 2 parents. (Case 1)
- If the added edge points to the root, all nodes will have 1 parent. (Case 2)
- For Case 1, find the node with 2 parents, removing the edge from either parent can create a directed tree.
- For Case 2, the shape is a unidirectional loop with trees growing from its nodes. Trace back from any node to detect the loop, then, breaking any of its edges can create a directed tree.

## 679. Calculate 24 given 4 numbers

- 4 numbers having 24 permutations; 3 bracket structures; 64 permutations of operators.
- Brute force. Floating point numbers should work.

## 668. Find the *n*th-largest number in a multiplication table

- Plot in 3 dimensions. It is a oblique plane. No, a curved surface.
- Back to 2 dimensions. Plot the table as a lattice, draw contour lines "x * y = z" for different "z" values.
- More or less: there is a contour line cutting the table into two halves, that the down-left half has area "n"... (Line 1)
- More precisely, find the exact contour line passing through lattice points, and that the total number of lattice points on its left, plus those on it, first exceeds "n".
- Start from Line 1. Calculate its position using a little ...calculus. Got its "z" value.
- Walk through Line 1 down the table, calculate the number of lattice points on its left, and those on it, sum.
- If the sum is too small or too large, move "z" up or down accordingly, repeat.
- Speedup: only walk once, record the point immediately on the left, and those on the right, sort both by "z" values. Not proven, though.
- And maybe there is just a formula...

## 660. The *n*th positive decimal not containing "9"

- Below 10 it is 0 to 8. Below 100 it repeats below-10, minus 90 to 99. A recursive calculation.
- Looks like a Cantor set. Maybe there is a formula?

(How many do they borrow from Project Euler?)

