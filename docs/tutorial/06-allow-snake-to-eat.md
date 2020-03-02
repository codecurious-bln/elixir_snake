### 6. Allow snake to eat

We have the food! But our snake can't eat it yet and we don't want to starve our little friend 🙀

The goal of this chapter is to allow the snake to eat the food and grow. Let's quickly recap how it works: The snake "eats" the food when it overlaps it with its head. As soon the snake has eaten, it grows by one unit (a new tile will be appended to its body) and a new food pellet will be placed somewhere in the game.

To achieve this, we'll check whether the snake's head has the same coordinates as the pellet. As we need to perform this check again after every movement, the `move_snake/1` function looks like a good place this.

👇Let's add it at the end of the state update pipeline, the pipe operator `|>` comes in handy here 💚

```elixir
defp move_snake(%{snake: snake} = state) do
  %{body: body, size: size, direction: direction} = snake

  # New head's position
  [head | _] = body
  new_head = move(state, head, direction)

  # Place a new head on the tile that we want to move to
  # and remove the last tile from the snake tail
  new_body = List.delete_at([new_head | body], -1)

  state
  |> put_in([:objects, :snake, :body], new_body)
  |> maybe_eat_pellet(new_head)
end
```

Our new function `maybe_eat_pellet/2` receives:

- The current state as 1st argument
- The snake's head coordinates as 2nd argument

If the snake's head overlaps the food pellet, we grow its body by one unit and place a new pellet somewhere in the game.

or otherwise, just return the current state without any changes.

Let's draft out the `maybe_eat_pellet/2` function and implement it step by step.

```elixir
def maybe_eat_pellet(state = %{pellet: pellet}, snake_head) when pellet == snake_head do
  state
  |> grow_snake()
  |> place_pellet()
end

def maybe_eat_pellet(state, _snake_head), do: state
```

Growing the snake's body can be tricky. Let's explore some possibilities:

Prepending a new tile before the snake's head is not feasible. It could lead to unexpected outcome: the snake hits its tail and dies ☠️

The most natural approach is appending a new tile to the end of the body. But how? We can't append a tile with `Enum.concat(body, [{x, y}])`. We can't infer the coordinates (`{x, y}`) for the new tile, since we don't know the tail's direction. We only know where the head is moving.

The only way to safely grow our snake its to preserve its body when it ate the pellet. We can set a boolean flag `has_eaten` in the state and on the next tick not delete the last body tile if is set to `true` 🤓. This will naturally grow our snake by one tile.

Remember, we set a timer at the beginning in out `init/1` function that periodically sends a message, which is intercepted by our `handle_info/2`, which in turn calls the `move_snake/1` function. That's our game tick.

Let's add these two new functions in our code:

- `grow_snake/1` sets the `:has_eatan` flag to true in the state
- `place_pellet/1` computes a new pair of coordinates for the food. If the new value matches any tile in the snake's body, it recursively generate a new position until it does not overlap any more.

```elixir
defp move_snake(%{snake: snake} = state) do
  %{body: body, size: size, direction: direction} = snake

  # New head's position
  [head | _] = body
  new_head = move(state, head, direction)

  # Place a new head on the tile that we want to move to
  # and remove the last tile from the snake tail
  new_body = List.delete_at([new_head | body], -1)

  state
  |> put_in([:snake, :body], new_body)
  |> maybe_eat_pellet(new_head)
end

def maybe_eat_pellet(state = %{pellet: pellet}, snake_head) when pellet == snake_head do
  state
  |> grow_snake()
  |> place_pellet()
end

def maybe_eat_pellet(state, _snake_head), do: state

def grow_snake(state = %{%{snake: %{size: size}}) do
  put_in(state, [:snake, :has_eaten], true)
end

def place_pellet(state = %{width: width, height: height, snake: %{body: snake_body}}) do
  pellet_coords = {
    Enum.random(0..(width - 1)),
    Enum.random(0..(height - 1))
  }

  if pellet_coords in snake_body do
    place_pellet(state)
  else
    put_in(state, [:objects, :pellet], pellet_coords)
  end
end
```

We still need to update the `move_snake/1` function to use the `:has_eatan` flag.

```elixir
defp move_snake(%{snake: snake} = state) do
  %{body: body, direction: direction} = snake

  # New head's position
  [head | _] = body
  new_head = move(state, head, direction)

  # Place a new head on the tile that we want to move to
  # and remove the last tile from the snake tail if it has not eaten any pellet
  new_body = [new_head | body]
  new_body = if snake.has_eaten, do: new_body, else: List.delete_at(new_body, -1)

  state
  |> put_in([:snake, :body], new_body)
  |> maybe_eat_pellet(new_head)
end
```

When `:has_eaten` is true, the last tile from the snake's body is **not** removed. This is the trick that allows us to grow the snake 💪

And now let's run the game and see how if our snake grows when eating.

    $ mix scenic.run

Oh snapp! Our snake is growing infinitely!! We forgot to reset the `:has_eaten` flag 🙈

```elixir
defp move_snake(%{snake: snake} = state) do
  %{body: body, direction: direction} = snake

  # New head's position
  [head | _] = body
  new_head = move(state, head, direction)

  # Place a new head on the tile that we want to move to
  # and remove the last tile from the snake tail if it has not eaten any pellet
  new_body = [new_head | body]
  new_body = if snake.has_eaten, do: new_body, else: List.delete_at(new_body, -1)

  state
  |> put_in([:snake, :body], new_body)
  |> put_in([:snake, :has_eaten], false) # Reset the `:has_eaten` flag before the next check
  |> maybe_eat_pellet(new_head)
end
```

Ok, let's run it again, it should work like a charm now 🤞

TODO:

- add gif
