# Game at the end of Chapter 5
defmodule Snake.Scene.Game5 do
  use Scenic.Scene

  import Scenic.Primitives, only: [rounded_rectangle: 3]

  alias Scenic.ViewPort
  alias Scenic.Graph

  @graph Graph.build(clear_color: :dark_sea_green)
  @tile_size 32
  @tile_radius 8
  @frame_ms 192

  def init(_arg, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    number_of_columns = div(vp_width, @tile_size)
    number_of_rows = div(vp_height, @tile_size)

    state = %{
      width: number_of_columns,
      height: number_of_rows,
      objects: %{
        pellet: {5, 5},
        snake: %{body: [{9, 9}, {10, 9}, {11, 9}], direction: {1, 0}}
      }
    }

    # start timer
    {:ok, _timer} = :timer.send_interval(@frame_ms, :frame)

    {:ok, state, push: @graph}
  end

  def handle_info(:frame, state) do
    new_state = move_snake(state)
    graph = @graph |> draw_objects(new_state.objects)

    {:noreply, new_state, push: graph}
  end

  defp move_snake(%{objects: %{snake: snake}} = state) do
    %{body: body, direction: direction} = snake

    # new head's position
    [head | _] = body
    new_head = move(state, head, direction)

    # place a new head on the tile that we want to move to
    # and remove the last tile from the snake tail
    new_body = List.delete_at([new_head | body], -1)

    state
    |> put_in([:objects, :snake, :body], new_body)
  end

  defp move(%{width: w, height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
    # We use the remainder function `rem` to make the snake appear from the opposite side
    # of the screen when it reaches the limits of the graph.
    x = rem(pos_x + vec_x + w, w)
    y = rem(pos_y + vec_y + h, h)
    {x, y}
  end

  defp draw_objects(graph, objects) do
    Enum.reduce(objects, graph, fn {type, object}, graph ->
      draw_object(graph, type, object)
    end)
  end

  # Pellet is simply a coordinate pair
  defp draw_object(graph, :pellet, {x, y}) do
    draw_tile(graph, x, y, fill: :orange)
  end

  # Snake's body is a list of coordinate pairs
  defp draw_object(graph, :snake, %{body: body}) do
    Enum.reduce(body, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :dark_slate_gray)
    end)
  end

  # draw tiles as rounded rectangles to look nice
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :black, translate: {x * @tile_size, y * @tile_size}], opts)
    rounded_rectangle(graph, {@tile_size, @tile_size, @tile_radius}, tile_opts)
  end

  # Keyboard controls
  def handle_input({:key, {"left", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {-1, 0})}
  end

  def handle_input({:key, {"right", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {1, 0})}
  end

  def handle_input({:key, {"up", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {0, -1})}
  end

  def handle_input({:key, {"down", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {0, 1})}
  end

  # Ignore all the other inputs
  def handle_input(_input, _context, state), do: {:noreply, state}

  # Change the snake's current direction.
  defp update_snake_direction(state, direction) do
    put_in(state, [:objects, :snake, :direction], direction)
  end
end
