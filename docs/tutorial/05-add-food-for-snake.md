### 5. Add food for snake

Our snake can move free, but it's still missing an another important piece of the game: the food pellet.

The food pellet is basically an object composed by one single tile and therefore can be represented by a pair of coordinates `{x,y}`.

In order to introduce it, we need to:
- Add the food to the initial state of the game, its coordinates must not overlap with the snake's body.
- Draw the food pellet each game tick as we are doing for the snake body, but its value won't change (at least for the moment).

For addressing the first point, we can simply update the initial state in the `init/2` function, and that's all.

```elixir
  def init(_arg, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    number_of_columns = div(vp_width, @tile_size)
    number_of_rows = div(vp_height, @tile_size)

    state = %{
      width: number_of_columns,
      height: number_of_rows,
      snake: %{body: [{9, 9}, {10, 9}, {11, 9}], direction: {1, 0}}
      pellet: %{5, 5}
    }

    # start timer
    {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

    {:ok, state, push: @graph}
  end
```

Then, we need to update our application to draw the food pellet each game tick.
If you look at the `init/2` function above, there is a timer that periodically sends a message, this is intercepted by our `handle_info/2` callback, which is in charge of moving the snake and then drawing it.

👆We need to update the `handle_info/2` to draw the food pellet as well.

```elixir
def handle_info(:frame, state) do
  new_state = move_snake(state)
  graph = @graph
  |> draw_snake(new_state)
  |> draw_food(new_state)

  {:noreply, new_state, push: graph}
end

# Pellet is simply a coordinate pair
defp draw_pellet(graph, %{pellet: {x, y}}) do
  draw_tile(graph, x, y, fill: :orange)
end

# Snake's body is a list of coordinate pairs
defp draw_snake(graph, %{snake: %{body: body}}) do
  Enum.reduce(body, graph, fn {x, y}, graph ->
    draw_tile(graph, x, y, fill: :dark_slate_gray)
  end)
end
```

TODO:
- generalize function `draw_object/2`
- add GIF
