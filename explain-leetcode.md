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
- Compare and swap
- Decompose a thing into smaller things
- Do it incrementally
- Induction, build on top of a lesser problem
- Layer by layer
- Remove the trivial
- Sorting
- Try basic examples
- Try evil examples
- Work backwards

## Caveats

- Always read the "Note" section, size constraints can change the game.
- "eerie" is a "subsequence" of "exercise".

## 761. Shuffle adjacent "special" substrings (whose 1-count "=" 0-count, and ">=" for all prefixes) to maximise the string

- When can we break a "special" string into two smaller ones...
- "1100" contains "10" in the middle, but such case doesn't matter.
- "Special"-ness guarantees a unique breakdown.
- After completely broken down, we have an array, now just sort them.
- But why is the whole input "special"?

## 759. When does everyone have free time

Interval calculation. A sorted set of pairs.

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

- Prefix trees?
- Prefixes -> (suffixes -> last position)

## 736. Lisp expression

Translate the spec into code. A simple expression evaluator.

## 732. Calendar overlap count

Interval calculation. A sorted set of pairs, each having a count.

## 727. Subsequence occurrence with the shortest span

- Build an index for each letter.
- Search letter by letter using the index.
- A shortcut: when looking for the target "ab...", skip "axxayyb" ahead to "ayyb".
- But this doesn't accumulate, working from target "ab..." to target "abc..." will need backtracking.
- So we should search in reverse instead, finding the nearest previous letter one by one.
- No, searching in reverse has exactly the same problem.
- So, go forwards finding the first occurrence letter by letter, then, start from the last found letter, search letter by letter in reverse; that is a local minimum span.
- Move forwards by 1 letter.
- Repeat, forwards-then-backwards each time.

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
- If the added edge points to a child node, there will be 1 node with 2 parents. (Case A)
- If the added edge points to the root, all nodes will have 1 parent. (Case B)
- For Case A, find the node with 2 parents, removing the edge from either parent can create a directed tree.
- For Case B, the shape is a unidirectional loop with trees growing from its nodes. Trace back from any node to detect the loop, then, breaking any of its edges can create a directed tree.

## 679. Calculate 24 given 4 numbers

- 4 numbers having 24 permutations; 3 bracket structures; 64 permutations of operators.
- Brute force. Floating point numbers should work.

## 668. Find the *n*th-largest number in a multiplication table

- Plot in 3 dimensions. It is a oblique plane. No, a curved surface.
- Back to 2 dimensions. Plot the table as a lattice, draw contour lines "x * y = z" for different "z" values.
- More or less: there is a contour line cutting the table into two halves, that the down-left half has area "n"... (Line A)
- More precisely, find the exact contour line passing through lattice points, and that the total number of lattice points on its left, plus those on it, first exceeds "n".
- Start from Line A. Calculate its position using a little... calculus. Got its "z" value.
- Walk along Line A down the table, calculate the number of lattice points on its left, and those on it, sum.
- If the sum is too small or too large, move "z" up or down accordingly, repeat.
- Speedup: only walk once, record the point immediately on the left/right, sort both by "z" values, then use them to amend the result. Not proven, though.
- And maybe there is just a formula...

## 660. The *n*th positive decimal not containing "9"

- Below 10 it is 0 to 8. Below 100 it repeats below-10, minus 90 to 99. A recursive calculation.
- Looks like a Cantor set. Maybe there is a formula?

(How many do they borrow from Project Euler?)

## 656. Minimum total score to jump to the destination on a line, given the maximum single-jump length

Induction. The minimum total score from Point 1 to Point N, for each N.

## 644. Max segment average, given the minimum segment length

- Think in calculus. Plot the "integration" as a curve.
- Then the task is to find the deepest slope, given the minimum horizontal length.
- Use an array of angles? Does not accumulate... It is inherently 2-dimensional.
- Some examples: convex, concave, "\\/\\/\\/" shape, "\\\\" shape.
- Is the convex closure useful for an incremental search? Not much.
- Begin from the maximum point and search leftwards? First skip the minimum-length window, then look leftwards for the deepest slope.
- It is either the first point we look (Point A), or another Point B on A's left with the deepest slope to A. To find that point, maybe walk leftwards and check each new minimum.
- Afterwards, go right, begin from the next-maximum point and repeat? But then, ">" shape will be slow.
- More examples. It does not necessarily involve the global maximum. Not necessarily a local maximum either. Need to search leftwards from each point instead.
- If we already know the deepest slope _to_ each point? Will solve the problem.
- So, can we calculate the deepest slope _to_ each point? Firstly scan from Point 1 to others, mark those in its line-of-sight... An evil example will be a concave curve...
- Doesn't matter. For each new point, only need to check its previous point (Point P), and then check the one point with the deepest slope to Point P.
- Maybe it is obvious in 4 dimensions...

## 642. Auto-complete

Only 100 items, use a sorted map.

## 639. Letters turned into 1 to 26, then concatenated without spacing, then some digits become almost illegible; count the possible original strings

- Unclear specification... From the last example we guess what it tries to say.
- Recursion. From left to right, given the first digit, recursion on the rest, add up the few cases. Need two functions.
- To speed up, iterate from right to left instead.

## 632. Use a range to cover at least one number from each sorted array, minimise the range

- Unspecified: how long are the arrays? Assume they are huge.
- The arrays can be sparse, and can have big "holes" in the middle. A range can fall through the "hole" and miss.
- The largest covering range is the smallest first number and the largest last number.
- Scan from left to right? Numbers from each array come and go... Not sure.
- If we plot the range-begin as X and the range-end as Y and calculate the coverage rate at each point? Not working...
- Scan from left to right. First, move the range-end rightwards until all arrays are covered. Use a vector to track the in-range element count of each array. Then, move the range-begin rightward... Until the coverage is broken. We get one local shortest range.
- Repeat, move range-end until full coverage, move range-begin until coverage broken, update the record.

## 631. Spreadsheet with formulas

- Translate the spec into code.
- Underlying, a directly acyclic graph of updates.
- Need to update layer by layer. Example: a -> b, a -> c, (a, b, c) -> d. Therefore need to maintain the layer index?
- Doesn't matter. Just spread all the changes in whatever order. (That's why it's called a spreadsheet?)

## 630. Schedule as many one-off tasks as possible, no overlapping, each task having a length and a deadline

- The end result will look like... A ladder shape of task lengths, one after another; and a dented shape of deadlines behind them.
- No point to idle between two tasks.
- Sort the result by the deadline? If two adjacent tasks (Task A before Task B) have Deadline A > Deadline B, we can swap them without violating their deadlines. By means of bubble sort, we can sort the whole result.
- So, sort all the tasks by the deadline, drop some, then will be the result.
- So, go through each task, either keep or drop it, iterate? Need to keep track of "how long for how many tasks, at best" in a map.
- No, it's slow for some examples.
- Sort by the length instead?
- Consider the first task in the result. It can always be replaced by a shorter task without problems. Then, by induction, yes.
- Sort by length; take the first task, or drop if cannot meet its deadline, repeat.
- May be useful one day.

## 629. Count those permutations which have a given number of pairwise inversions

- Good old combinatorics. An easy recursive function, or an iteration. But the speed...
- However, the requested number of inversions is "small". At most need to calculate less than a million numbers.
- That is, about half a billion additions and a million moduli. May be fine for the C language on a 64-bit machine.

## 600. Count those binary numbers which do not contain "11", below an upper bound

- Recursion by the length.
- Slow down when approximating the upper bound, bit by bit.

## 591. XML validator

Translate the spec into code. A stack, and a state machine for different parsing modes.

## 588. Simulate files and directories

Prefix tree.

## 587. Convex closure of lattice points

- First find the bounding box. Then only keep the first/last points of each row, together with the first/last rows.
- Need to "circle" around the area to wrap it. But how?
- Break the points into 4 segments, each segment touches the bounding box at its beginning and end.
- Work clockwise on an segment. Start from Point 1, find the (nearest) point with the max slope to Point 1. Mark it as Point 2. Repeat.
- Special cases: less than 4 segments, points on the bounding box.

## 568. "Maximise vacation"

- No work ethic?
- A directed graph?
- Rephrase the problem: a directed graph of layers, same number of nodes in each layer, and same set of arrows between each two adjacent layers, nodes have different scores; maximise the total score from the starting node to the last layer.
- From the starting node down, only keep the reachable arrows.
- Layer by layer, calculate the maximum score getting to each node.

## 564. The nearest (smallest) palindrome number from a given number

- Palindrome numbers can be cut in halves. Increase or decrease the left half by one, that's the next/previous palindrome number.
- That is, when they have the same length. Numbers like 10001 and 99999 are the first and the last.
- Cut the given number by half, mirror image the half to get a palindrome, then find the other palindrome on the other side of the given number, compare the distances, pick.
- Special case: given 10000.

## 552. Count the trit strings with at most one "1" and at most two "2"s, given the length

- Induction on the length. But this is slow.
- Simple combinatorics, six cases.

## 527. Unambiguous abbreviation of each among the given words; "apple" can become "a3e" or "ap2e"

- Convert "apple" into (5, "e", "appl"), that is, the length, the last letter, and the prefix word.
- Group by the length and the last letter.
- For each group of prefix words, sort.
- Go down the group, mark where each word differs from the previous word above.
- Now we have a dented shape... When the mark goes left, it is easy; but when it goes right...
- Not exactly. Also need to go up and mark the difference against the word below?
- Not needed. Each word has two marks against the two adjacent words, pick the longer one, abbreviate up to there.

## 517. Share items among a line of boxes so that the boxes end up with the same number of items, minimise the number of rounds; each round each box can pass 1 item to an adjacent box

- If the number of boxes divides the number of items, this can be done, at least by (slowly) passing one item at a time.
- Some examples...
- No point to pass items _both_ from Box A to Box B _and_ from Box B to Box A, which wastes 2 rounds doing nothing.
- Draw the initial boxes as a histogram, draw a line at the average number. Then need to move the items above the line into the "holes" below.
- It is deterministic which items get into which hole. Start from the first hole on the left, draw from the leftmost available items until the hole is filled, repeat.
- Now we know, for each "column" of items in the histogram (above the average line), which holes it fills, and how deep they are.
- Now need to minimise the number of rounds, for each column. That is, how long the "last" item takes to get into its destination.
- Example: 2 -1 -1. Example: -5 10 -5. Another example: -1 0 0 0 0 0 3 -2. There is no simple rule to tell which item is the "last".
- Work backwards? Turn it upside-down so that the items in the holes flows into one column. Doesn't work...
- In some cases, holes "delays" each other. For example -5 -5 0 10.
- Draw each hole as a line, first draw its distance from the column, followed by it depth. We get a picture of "parallelism".
- When two "depths" overlap, there will be delays.
- Sort by the beginning of the depth. Check the first hole line, if its depth overlaps with the next line's, then move the next line's depth rightwards. Repeat. The end of the last depth is the answer (for the one column). Repeat on those columns which fills two or more holes.

## 514. "Dial" a sequence of numbers using a ring of numbers, minimise the total movement

- The extra "enter" button doesn't matter.
- A directed graph of layers, minimise the total cost to move to last layer.
- Layer by layer, calculate the minimum cost to get to each desired number.

