[![CircleCI](https://circleci.com/gh/codecurious-bln/elixir_snake.svg?style=svg)](https://circleci.com/gh/codecurious-bln/elixir_snake)

# Build a Snake game to learn Elixir

This tutorial is about building a Snake game with Scenic to teach Elixir.

The tutorial is heavily based on the following article: [Getting started with Scenic in Elixir — Crafting a simple snake game].

See the [guides](./docs/GUIDES.md) for the workshop material.

## TODOs

So far the tutorial is given as a set of files, see [Files](#files). This needs to be fleshed out into a written tutorial.

We should also think about further reducing complexity. If we want to make changes to the game I would suggest to do so in the final version (i.e. in `lib/game6.ex`) first. We can then retrofit them to the other files.

## Setup

Set up the project in order to view and run sample solutions for each step of the tutorial.

### Installation

1.  Install Erlang and Elixir on your machine. Scenic requires Erlang/OTP 21 (or newer) and Elixir 1.7 (or newer).

    _(In case you're using the [asdf version manager](https://github.com/asdf-vm/asdf), install the respective plugins for Erlang/Elixir and run `asdf install`.)_

1.  Install Open GL libraries for _(for [scenic_new](https://github.com/boydm/scenic_new))_

    On macOS 🍏:

        $ brew install glfw3 glew pkg-config

    On Ubuntu 18 🐧:

        $ sudo apt-get install pkgconf libglfw3 libglfw3-dev libglew2.0 libglew-dev

    _(See https://github.com/boydm/scenic_new#install-prerequisites for details on other operating systems.)_

1.  Install the `scenic.new` mix task _(Mix task to easily generate a Scenic app)_:

        $ mix archive.install hex scenic_new

### Project dependencies

Download the elixir dependencies from the project with:

    $ mix deps.get

### Running

Run the game with:

    $ mix scenic.run

### Files

- `lib/snake.ex` - starter application
- `lib/game_original.ex` - original implementation from [Getting started with Scenic in Elixir — Crafting a simple snake game]
- `config/config.exs` - App config. Adjust the `default_scene` parameter to use the different scenes (Game1, Game2) described below.

So far the tutorial is given as a set of files, slowly building up the game:

- `lib/game1.ex` - Initial setup with pellet. This is used to explain the basics.
- `lib/game2.ex` - Setup to live-code the basic snake movement. Adds a skeleton for the movement functions.
- `lib/game3.ex` - The result of live-coding the snake movement.
- `lib/game4.ex` - Add input control and setup for live-coding pellet eating.
- `lib/game5.ex` - Result of live-coding pellet eating.
- `lib/game6.ex` - Final Game, implements dying.

## Tips & Tricks

- use [prettier CLI](https://prettier.io/docs/en/cli.html) to automatically format the markdown files:

      npx prettier --write <path-to-file>

[getting started with scenic in elixir — crafting a simple snake game]: https://blog.usejournal.com/elixir-scenic-snake-game-b8616b1d7ee0
