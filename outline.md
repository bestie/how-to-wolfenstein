
# How to Wolfenstein on the terminal

## TDD problem

This is a 'graphical' game and the acceptance criteria is roughly:

'Does this fool my brain into perceiving a three dimensional space?'

I have so far failed to propose a sensible high-level test would tell me
if I'd achieved the goal beyond matching fixtures which would be brittle and
would require me to draw my expected output in advance.

This is not fun.

## Choosing what to test

We can write tests (in advance) for most of the lower level components.

Components that are hard to test will be made trivially small to increase confidence.
This includes things like the game loop and terminal handling.

Acceptance tests have to be verified with your eyes.

There is no test for fun.

However, I have no patience for fiddling with UIs manually,
there will be a trick for making this easier.

## Phases

### Level editor

We will define a layout / level in our text editor and write some code to
interpret that and answer some questions about it.

### Terminal user interface and game loop

Now we have a map we can move around it and print the map / player position to
the screen.

Use of `io/console` will make it more responsive.

### Demo mode

Every good game has a demo mode and if our game was able to play itself that
would make our human-based acceptance testing way easier.

Let's take advantage of the dependency injection we already have to make that
trivially easy.

### Rendering (pseudo) 3D

Using a simple ray tracing / casting technique we will measure how far away the
walls are from our current position in a given direction.

Pseudo 3D means that this 'distance to wall' value is the same for an entire
vertical slice of the projected image. Therefore we need to write a function
that renders a vertical slice our the projection for each column of the terminal.

### Add depth / brightness

Using some basic maths we can calculate the relative light intensity for a distance
and choose an ASCII character that appears lighter / darker.

Walls in a column/slice will appear at the same brightness.

The floor will appear to less bright the further away (higher in the column) it is.

### Performance

What we care about is frames per second, let's measure that and report after
the game.

Using RubyProf we see that vector calculations and repeated method calls are
taking a lot of time.

Introducing our own mutable vector class will speed things up a lot.
