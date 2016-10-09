Life in Ruby with No Mutations
===

This was inspired by the "no mutations" round
in the [Code Retreat](http://coderetreat.org/) day
of [Ruby DCamp](http://rubydcamp.org/).
I started it while pairing with Kalimar Maia,
and of course we didn't finish it,
but it piqued my interest so I finished it later.
(No, I didn't test-drive the rest of it.)

To run it, go into irb, load it, and run `World.run`.
By default, this will give you a world of
80 columns and 20 rows,
with a delay of 1/20 of a second
between iterations.
You can pass it a hash of options, including (each being optional):

- cols: the number of columns
- rows: the number of rows
- delay: delay in seconds between iterations (yes, 0 is OK)

Each iteration will show the state of the world
(or rather, show the current world),
with its number and how many cells it contains.
Once it has reached stability
(defined as the same set of cells as
sometime in the past 15 iterations),
it will halt, reporting the
cycle length
and
number of iterations per second.

You could also run it in a loop, with a command like:
`while true ; World.run ; sleep 1 ; end`
(inlcuding your desired options).

Notes:

- This relies on ANSI escape sequences,
so if its output looks like a load of garbage,
go figure out how to turn those on for
whatever sort of system you're using.
Don't ask me.

- Since Ruby does not do tail-recursion optimization
(at least by default,
and I didn't want to bother turning it on),
you may run out of stack space,
but it will quite some time.
I have not hit the wall
even after many runs
at 132 columns by 66 rows.

- Yes, it does I/O, which is mutating the state of the screen.
If you're inclined to quibble about this,
[go stick your head in a pig](https://www.youtube.com/watch?v=_wSBC5Dyds8).
