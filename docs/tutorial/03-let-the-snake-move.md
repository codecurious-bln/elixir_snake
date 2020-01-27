### 3. Let the Snake Move

The fast and constantly moving snake is what makes the game challenging to play. Players can only "steer" the direction the snake is turning to. The always hungry animal is automatically moving forward all the time.

To add this aspect to our currently static game scene, we need to periodically update the graph and re-render the scene, moving the position of our snake one tile forward each time. Being a `GenServer` process under the hood, our `Game` scene can send and receive messages from any Elixir process, including itself. When initializing the scene, we'll also start a periodically ticking timer that will send a message to the scene process every time the snake position should change. We can make use of Erlang's built in `:timer` module for that and send a `:frame` message every `192` milliseconds to our `GenServer`.

> Coach: Explain interoperability between Elixir and Erlang.

```elixir
@graph Graph.build(clear_color: :dark_sea_green)
@tile_size 32
@frame_ms 192

def init(_arg, opts) do
  viewport = opts[:viewport]

  {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

  number_of_columns = div(vp_width, @tile_size)
  number_of_rows = div(vp_height, @tile_size)

  state = %{
    width: number_of_columns,
    height: number_of_rows
  }

  snake = %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5}
  graph = draw_object(@graph, snake)

  # start timer
  {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

  {:ok, state, push: graph}
end
```

Then we need to implement the `handle_info/2` callback function where our scene process can receive incoming messages in the format `{type, state}`. We'll match on the `type` tuple to make sure we're handling the right message. We'll for now just output some logging information to see what's happening:

```elixir

def init(_arg, opts) do
  # ...
  {:ok, state, push: graph}
end

def handle_info(:frame, state) do
  IO.puts("tick")

  {:noreply, state}
end
```

In order to move the snake one tile forward, we need to keep track of its position. We can achieve this by including the `snake` in the scene's state:

```elixir
def init(_arg, opts) do
  # ...

  state = %{
    width: number_of_columns,
    height: number_of_rows,
    snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5}
  }

  graph = draw_objects(@graph, state)

  {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

  {:ok, state, push: graph}
end
```

We'll also turn our `draw_object/2` function into a `draw_objects/2` function. Instead of just the snake object, we'll pass the whole state as the second argument.

```elixir
defp draw_objects(graph, %{snake: %{body: body}}) do
  Enum.reduce(body, graph, fn {x, y}, graph ->
    draw_tile(graph, x, y, fill: :dark_slate_gray)
  end)
end
```

There's one last piece of information missing before we start working on making the snake move. We need to add the snake direction to the state, so that we know how to move it. Later on, we'll be able to change its direction, but for now it will only move to the right.

```elixir
state = %{
  width: number_of_columns,
  height: number_of_rows,
  snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5, direction: {1, 0}}
}
```

The snake movement is described by a shift of its body coordinates. Looking at the list that represents the snake body, we can see that this is equivalent to adding a new pair of coordinates to the beginning of the list and removing another from the end, so that the snake size is preserved.

Now that we have our snake movement logic figured out, let's go ahead and implement a `move_snake/1` function.

```elixir
defp move_snake(%{snake: snake} = state) do
  %{body: body, size: size, direction: direction} = snake

  # new head
  [head | _] = body
  new_head = move(state, head, direction)

  # truncate body
  new_body = Enum.take([new_head | body], size)

  state
  |> put_in([:snake, :body], new_body)
end

defp move(%{width: w, height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
  x = rem(pos_x + vec_x + w, w)
  y = rem(pos_y + vec_y + h, h)
  {x, y}
end
```

When calculating the new coordinates in the code snippet above, we use the remainder function `rem` to make the snake appear from the opposite side of the screen when it reaches the limits of the graph.

The next step will be to update our `handle_info/2` callback with the function we just created. We'll also do some refactoring to make things cleaner, by delegating the responsibility of drawing the objects in the graph and pushing it to the viewport to our `handle_info/2` callback, instead of `init/2`. After these changes, our `handle_info/2` callback will look like this:

```elixir
def handle_info(:frame, state) do
  new_state = move_snake(state)
  graph = draw_objects(@graph, new_state)

  {:noreply, new_state, push: graph}
end
```

So at every tick of the timer, the state of the scene will be updated with the new coordinates of the snake body and the snake object will be added on top of the initial `@graph`. The `init/2` callback will be responsible only for setting up the initial state, triggering a timer to send a message to our scene at each `@frame_ms` interval and pushing the initial `@graph`. Here's how it should look like now:

```elixir
def init(_arg, opts) do
  viewport = opts[:viewport]

  {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

  number_of_columns = div(vp_width, @tile_size)
  number_of_rows = div(vp_height, @tile_size)

  state = %{
    width: number_of_columns,
    height: number_of_rows,
    snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5, direction: {1, 0}}
  }

  # start timer
  {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

  {:ok, state, push: @graph}
end
```

As a last step before we move on to the next chapter, let's update the viewport size in the `config/config.exs` file, so that the snake better fits to it.

```elixir
config :snake, :viewport, %{
  # ...
  size: {704, 608},
  # ...
}
```
