### 1. Create a scenic app

First off we'll create a new Scenic application using our previously installed `scenic_new` mix task. We are building a snake game, so let's call our project `snake`. The `scenic_new` package gives us the handy `scenic.new` task which can be used to bootstrap a new Scenic application.

The task makes some assumptions about the typical structure of a Scenic application. It will generate a skeleton for our snake app with all directories and files already in place. This is "boilerplate" code we would otherwise need to write by hand.

Run this in you terminal:

    $ mix scenic.new snake

You will see output like this:

    * creating .formatter.exs
    * creating .gitignore
    * creating README.md
    * creating mix.exs
    * creating config
    * creating config/config.exs
    * creating lib
    * creating lib/components
    * creating lib/snake.ex
    * creating lib/scenes
    * creating lib/scenes/home.ex
    * creating priv/static
    Your Scenic project was created successfully.
    Next steps for getting started:
        $ cd snake
        $ mix deps.get
    You can start your app with:
        $ mix scenic.run
    You can also run it interactively like this:
        $ iex -S mix

We see it generated some files inside a new `snake` folder and gives us hints about what we can do next.

First, we need to navigate into our new project directory:

    $ cd snake

Let's see what we got:

    $ ls

We will have a look at the `mix.exs` file - open the file in your editor.

This file contains some core information about our project. There is a `deps` section at the bottom of the file listing the dependencies needed for running the project. The dependencies are other Elixir libraries, hosted as "hex" packages on [hex.pm](https://hex.pm)

> Coach: talks about hex and package managers

    defp deps do
      [
        {:scenic, "~> 0.10"},
        {:scenic_driver_glfw, "~> 0.10", targets: :host}
      ]
    end

To run the app, we need install the listed libraries.
`mix` also gives us a task to do that, let's run it in the terminal:

    $ mix deps.get

Now we are ready to run new Scenic project and check that everything is working 🤞. The `scenic_new` package also gives us a command to run our project:

    $ mix scenic.run

We should see a window similar to this:

![sceenshot](./../images/01-scenic-new-screen.png)

[Let's draw a snake](./02-draw-a-snake.md)
