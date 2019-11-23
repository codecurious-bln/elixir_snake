# Guides

Material for building the workshop tutorial.

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

## Tutorial

We want to learn more about the [Elixir](https://elixir-lang.org) programming language by building a fun game together: **snake** - a cult game from mobile phones in the 1990s 🕹

![snake game on a nokia phone](https://media.giphy.com/media/ZYOybCzZvpcY0/giphy.gif)

The game works as follows:  
> The player controls a moving snake which has to "eat" as many items as possible by running into them with its head. Each item makes the snake grow longer and the game is lost when the head runs into the tail.

We will implement the game using [Scenic](https://github.com/boydm/scenic), a library for building native macOS or Linux applications with graphical user interfaces in Elixir.

[So let's build a fun game together!](./tutorial/00-getting-ready.md)
