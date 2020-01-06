### 3. Let the Snake Move

The fast and constantly moving snake is what makes the game challenging to play. Players can only "steer" the direction the snake is turning to. The always hungry animal is automatically moving forward all the time.

To add this aspect to our currently static game scene, we need periodically update the graph and re-render the scene, moving the position of our snake one tile forward each time. Being a `GenServer` process under the hood, our `Game` scene can send and receive messages from any Elixir process, including itself. When initializing the scene, we'll also start a periodically ticking timer that will send a message to the scene process every time the snake position should change. We can make use of Erlang's built in `:timer` module for that and send `:frame` message every `192` milliseconds.

> Coach: Explain interoperability between Elixir and Erlang.

```elixir
@graph Graph.build(clear_color: :dark_sea_green)
@tile_size 32
@frame_ms 192

def init(_arg, opts) do
  viewport = opts[:viewport]

  {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

  num_tiles_width = trunc(vp_width / @tile_size)
  num_tiles_height = trunc(vp_height / @tile_size)

  state = %{
    width: num_tiles_width,
    height: num_tiles_height
  }

  snake = %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5}
  graph = draw_object(@graph, snake)

  # start timer
  {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

  {:ok, state, push: graph}
end
```

Then we need to implement the `handle_info/2` callback function where our scene process can receive incoming messages in the format `{type, state}`. We'll match on the `type` tuple to make sure are handling the right message. We'll for now just output some logging information to see what's happening:

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

In order to move the snake one tile forward, we need to keep track about its position in the game state. So let's refactor our state initialization to include the `snake` in the scene's state:

```elixir
def init(_arg, opts) do
  viewport = opts[:viewport]

  {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

  num_tiles_width = trunc(vp_width / @tile_size)
  num_tiles_height = trunc(vp_height / @tile_size)

  state = %{
    width: num_tiles_width,
    height: num_tiles_height,
    snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5}
  }

  graph = draw_objects(@graph, state)

  {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

  {:ok, state, push: graph}
end
```

We'll also turn our `draw_object/2` function into an `draw_objects/2` function. Instead of just the snake object, we'll pass the whole state as the second argument.

```elixir
defp draw_objects(graph, %{snake: %{body: body}}) do
  Enum.reduce(body, graph, fn {x, y}, graph ->
    draw_tile(graph, x, y, fill: :dark_slate_gray)
  end)
end
```


- add direction to snake

```elixir
state = %{
  width: num_tiles_width,
  height: num_tiles_height,
  snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5, direction: {1, 0}}
}
```

- add function to move snake and return new state:

```elixir
defp move_snake(%{snake: snake} = state) do
  %{body: body, size: size, direction: direction} = snake

  # new head
  [head | _] = body
  new_head = move(state, head, direction)

  # truncate body
  new_body = Enum.take([new_head | body], size)

  state
  |> put_in([:objects, :snake, :body], new_body)
end

defp move(%{width: w, height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
  x = rem(pos_x + vec_x + w, w)
  y = rem(pos_y + vec_y + h, h)
  {x, y}
end
```

- need to call the `move` function in our `handle_info` function with every tick and the update the scene again
- problem: need access to the graph there in order to render new stuff
- solution: add the graph to the game state

```elixir
state = %{
  graph: @graph,
  width: num_tiles_width,
  height: num_tiles_height,
  snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5, direction: {1, 0}}
}

# update the graph and push it to be rendered
graph = draw_objects(state.graph, state)
```

- update handle_info function to draw a new graph
- basically all scene callbacks support a `push: graph` option (https://hexdocs.pm/scenic/overview_scene.html#pushing-a-graph)
```elixir
def handle_info(:frame, state) do
  new_state = move_snake(state)
  graph = draw_objects(new_state.graph, new_state)

  {:noreply, new_state, push: graph}
end
```

- update configureation so that snake better fit for window size in config file:
```elixir
config :snake, :viewport, %{
  name: :main_viewport,
  size: {704, 608},
  default_scene: {Snake.Scene.Game, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "snake"]
    }
  ]
}
```

- with that in place, we can skip pushing the initial graph in the init function:
```elixir
def init(_arg, opts) do
  viewport = opts[:viewport]

  {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

  num_tiles_width = trunc(vp_width / @tile_size)
  num_tiles_height = trunc(vp_height / @tile_size)

  state = %{
    graph: @graph,
    width: num_tiles_width,
    height: num_tiles_height,
    snake: %{body: [{9, 9}, {10, 9}, {11, 9}], size: 5, direction: {1, 0}}
  }

  # start timer
  {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

  {:ok, state, push: @graph}
end
```

- with the graph being part of the state, also not necessary to pass it to our draw_objects function:
```elixir
defp draw_objects(%{graph: graph, snake: %{body: body}}) do
  Enum.reduce(body, graph, fn {x, y}, graph ->
    draw_tile(graph, x, y, fill: :dark_slate_gray)
  end)
end
```


- need to add snake position to the state to that we know where to move it
- snake needs to be able to disappear at one end and reappear on the other side (use rem)




### 4. Add food for the worm

### 5. Control worm movement

### 6. Allow worm to eat

### 7. Allow worm to die

### 8. Add static score

### 9. Add live scoring

### 10. Potential later steps

- move things into components (e.g. the score, the snake)
- add multiplayer
