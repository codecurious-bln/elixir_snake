### 6. Allow snake to eat

We have the food, but our snake can't eat it yet, and we don't want to starve our little friend.

The goal of this chapter is to allow the snake to eat the food and grow, but let's first quickly recap how it works. The snake eats the food when it overlaps it with its head, as soon the snake eats it, it will grow of one unit (a new tile will be appended to its body) and a new food pellet will be placed in the snake world.

In other words, we need to check if the snake's head has the same coordinates of the pellet after every movement. The function `move_snake/1` looks the natural place where to execute this check.

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
  |> maybe_eat_food(new_head)
end
```

👆Let's add it at the end of the state update pipeline, the pipe operator `|>` comes in handy here 💚

Our new function `maybe_eat_food/2` receives:

- The current state as 1st argument
- The snake's head coordinates as 2nd argument

Then, in the case the snake's head overlaps the food pellet, the function will take care of:

- Grow the snake body of one unit
- Place a new food pellet in the snake world

or otherwise, just return the current state without any changes.

Let's draft out the `maybe_eat_pellet/2` function and implement it step by step.

```elixir
def maybe_eat_pellet(state = %{pellet: pellet}, snake_head) do
  if (pellet == snake_head)
    state
    |> grow_snake()
    |> place_pellet()
  else
    state
  end
end
```

Growing the snake body can be tricky, let's explore all our alternatives.

Prepending a new tile to the snake head is not a feasible solution because it will potentially lead to unexpected outcome like its dead :skull:.

The most natural approach is to append a new tile at the end of the snake body, but how exactly? We can not simply add a new tile at the end like: `Enum.concat(body, [{x, y}])` since we don't have any information of the tail direction but only of its head. In other words, we can't infer the coordinates (`{x, y}`) of the tile to append. The only way to safely grow our snake it's to preserve its body when the snake ate the pellet. We could set a boolean flag `has_eaten` in the state and in the next game tick, don't delete the last snake's body tile when this flag is true 🤓.

Remember, we set a timer at the beginning in out `init/1` function that periodically sends a message, which is intercepted by our `handle_info/2`, which in turn calls the `move_snake/1` function. That's our game tick.

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
  |> maybe_eat_food(new_head)
end

def maybe_eat_pellet(state = %{pellet: pellet}, snake_head) do
  if (pellet == snake_head)
    state
    |> grow_snake()
    |> place_pellet()
  else
    state
  end
end

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

Let's take a look to these two new functions:

- `grow_snake/1` simply sets the `:has_eatan` flag to true in the state
- `place_pellet/1` computes a new pair of coordinates for the food, if the new value matches any tile in the snake's body, it recursively generate a new position until it does not overlap the snake

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
  |> maybe_eat_food(new_head)
end
```

Like that, when the flag `:has_eatan` is true, the last tile from the snake's body is not removed anymore. This is the trick that allows us to grow the snake 💪

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
  |> put_in([::snake, :has_eaten], false) # Reset the `:has_eaten` flag before the next check
  |> maybe_eat_food(new_head)
end
```

Ok, let's run it again, it should work like a charm now 🤞

TODO:

- add gif
