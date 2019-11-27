### 0. Getting ready

We first need to make sure we have Elixir installed on our computer. [Installing Elixir](https://elixir-lang.org/install.html) has installation instructions for all tastes and operating systems.

Once installed, check the version by running this command in your terminal:

    $ elixir --version

If your version is lower than `1.9.x`, either update to a more recent version or ask a coach for help.

Next, we'll install some `mix` tasks to help us build a `Scenic` application. [mix](https://hexdocs.pm/mix/Mix.html) is a tool that comes with Elixir to help developing apps and manage their dependencies. It is similar to e.g. `npm` in JavaScript (don't worry if you don't know that).

Specifically, we will use the `scenic_new` tasks which require some additional libraries installed on your computer. See the [install prerequisites](https://github.com/boydm/scenic_new#install-prerequisites) for installation instructions for your operating system.

Once everything is set up, you can install the tasks via `mix`:

    $ mix archive.install hex scenic_new

Now we are prepared to start building our Scenic application!

Navigate into your personal projects directory _(or wherever you want to keep the files for the tutorial)_ and then let's get started 🚀

[Let's create a scenic app](./01-create-a-scenic-app.md)
