# Build a Snake game to learn Elixir

This tutorial is about building a Snake game with Scenic to teach Elixir. 

The tutorial is heavily based on the following article: [Getting started with Scenic in Elixir — Crafting a simple snake game].

## TODOs

So far the tutorial is given as a set of files, see [Files](#files). This needs to be fleshed out into a written tutorial.

We should also think about further reducing complexity. If we want to make changes to the game I would suggest to do so in the final version (i.e. in `lib/game6.ex`) first. We can then retrofit them to the other files.

## Setup

Set up the project in order to view and run sample solutions for each step of the tutorial.

### Installation

1. Install Erlang and Elixir on your machine - the required versions can be found in the `.tool-versions` file:

        cat .tool-versions

  _(In case you're using the [asdf version manager](https://github.com/asdf-vm/asdf), install the respective plugins for Erlang/Elixir and run `asdf install`.)_

1. Install Open GL libraries for _(for [scenic_new](https://github.com/boydm/scenic_new))_

  On macOS 🍏:
        
        brew install glfw3 glew pkg-config

  On Ubuntu 18 🐧:

        sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev

  _(See https://github.com/boydm/scenic_new#install-prerequisites for details on other operating systems.)_

1. Install the `scenic.new` mix task _(Mix task to easily generate a Scenic app)_:

        mix archive.install hex scenic_new

### Running

Run the game with:

    mix scenic.run

### Files

* `lib/snake.ex` - starter application
* `lib/game_original.ex` - original implementation from [Getting started with Scenic in Elixir — Crafting a simple snake game]
* `config/config.exs` - App config. Adjust the `default_scene` parameter to use the different scenes (Game1, Game2) described below.

So far the tutorial is given as a set of files, slowly building up the game:

* `lib/game1.ex` - Initial setup with pellet. This is used to explain the basics.
* `lib/game2.ex` - Setup to live-code the basic snake movement. Adds a skeleton for the movement functions.
* `lib/game3.ex` - The result of live-coding the snake movement.
* `lib/game4.ex` - Add input control and setup for live-coding pellet eating.
* `lib/game5.ex` - Result of live-coding pellet eating.
* `lib/game6.ex` - Final Game, implements dying.


## Create a Scenic App

Create a new scenic application from scratch:

```
$ mix scenic.new snake
$ cd snake
$ mix deps.get

# test
$ mix scenic.run
```

## Concepts 

### Elxir Basics

We need to explain some Elixir basics like the data structures we use. We should have a look at the [Elixir Girls Elixir Beginners Guide](https://elixirgirls.com/guides/elixir-beginners-guide.html) for this. 

A first collection things we need to explain (very incomplete):

* iex
* data types
    * atoms
* data structures
    * tuple
    * list
    * map
* operators
    * pipe
* Enum module
* event loop
* ...

### Grid

The playing field is a grid of tiles, addressable like a coordinate system.

* x-Axis: 21 Tiles (tile 0 to 20)
* y-Axis: 18 Tiles (tile 0 to 17)

<pre>

   │ 0│ 1│ 2│ 3│ 4│ 5│ 6│ 7│ 8│ 9│10│11│12│13│14│15│16│17│18│19│20│
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  0│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 0
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  1│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 1
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  2│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 2
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  3│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 3
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  4│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 4
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  5│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 5
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  6│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 6
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  7│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 7
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  8│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 8
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
  9│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │ 9
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 10│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │10
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 11│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │11
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 12│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │12
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 13│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │13
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 14│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │14
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 15│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │15
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 16│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │16
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
 17│  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │  │17
───┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼──┼───
   │ 0│ 1│ 2│ 3│ 4│ 5│ 6│ 7│ 8│ 9│10│11│12│13│14│15│16│17│18│19│20│

</pre>



[Getting started with Scenic in Elixir — Crafting a simple snake game]: https://blog.usejournal.com/elixir-scenic-snake-game-b8616b1d7ee0
