defmodule Snake.Scene.Game6 do
  use Scenic.Scene

  import Scenic.Primitives, only: [rrect: 3, text: 3]

  alias Scenic.Graph
  alias Scenic.ViewPort

  # Constants
  @graph Graph.build(font: :roboto, font_size: 36)
  @tile_size 32
  @tile_radius 8
  @frame_ms 192
  @game_over_scene Snake.Scene.GameOver

  # Initialize the game scene
  def init(_arg, opts) do
    viewport = opts[:viewport]

    # calculate the transform that centers the snake in the viewport
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    # dimensions of the grid (21x18 tiles, 0-indexed)
    num_tiles_width = trunc(vp_width / @tile_size)
    num_tiles_height = trunc(vp_height / @tile_size)

    # start a very simple animation timer
    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    # The entire game state will be held here
    state = %{
      viewport: viewport,
      width: num_tiles_width,
      height: num_tiles_height,
      graph: @graph,
      frame_count: 1,
      frame_timer: timer,
      score: 0,
      objects: %{
        pellet: {5, 5},
        snake: %{body: [{9, 9}], size: 5, direction: {1, 0}}
      }
    }

    {:ok, state}
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

  def handle_input(_input, _context, state), do: {:noreply, state}

  # Change the snake's current direction.
  defp update_snake_direction(state, direction) do
    put_in(state, [:objects, :snake, :direction], direction)
  end

  def handle_info(:frame, %{frame_count: frame_count} = state) do
    state = move_snake(state)

    graph =
      state.graph
      |> draw_score(state.score)
      |> draw_game_objects(state.objects)

    {:noreply, %{state | frame_count: frame_count + 1}, push: graph}
  end

  # Move the snake to its next position according to the direction. Also limits the size.
  defp move_snake(%{objects: %{snake: snake}} = state) do
    %{body: body, size: size, direction: direction} = snake

    # new head
    [head | _] = body
    new_head = move(state, head, direction)

    # truncate body
    new_body = Enum.take([new_head | body], size)

    state
    |> put_in([:objects, :snake, :body], new_body)
    |> maybe_eat_pellet(new_head)
    |> maybe_die()
  end

  defp move(%{width: w, height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
    x = rem(pos_x + vec_x + w, w)
    y = rem(pos_y + vec_y + h, h)
    {x, y}
  end

  def maybe_eat_pellet(state = %{objects: %{pellet: pellet}}, snake_head) when pellet == snake_head do
    state
    |> grow_snake()
    |> place_pellet()
    |> update_score()
  end

  def maybe_eat_pellet(state, _) do
    state
  end

  def grow_snake(state = %{objects: %{snake: %{size: size}}}) do
    put_in(state, [:objects, :snake, :size], size + 1)
  end

  def place_pellet(state = %{width: w, height: h, objects: %{snake: %{body: snake_body}}}) do
    pellet_coords = {
      Enum.random(0..(w - 1)),
      Enum.random(0..(h - 1))
    }

    if pellet_coords in snake_body do
      place_pellet(state)
    else
      put_in(state, [:objects, :pellet], pellet_coords)
    end
  end

  def update_score(state = %{score: score}) do
    %{ state | score: score + 100}
  end

  def maybe_die(state = %{viewport: vp, objects: %{snake: %{body: body}}, score: score}) do
    # If ANY duplicates were removed, this means we overlapped at least once
    if length(Enum.uniq(body)) < length(body) do
      ViewPort.set_root(vp, {@game_over_scene, score})
    end
    state
  end

  #
  # -- DRAWING
  #

  # Draw the score HUD
  defp draw_score(graph, score) do
    graph
    |> text("Score: #{score}", fill: :white, translate: {@tile_size, @tile_size})
  end

  defp draw_game_objects(graph, objects) do
    Enum.reduce(objects, graph, fn {type, object}, graph ->
      draw_object(graph, type, object)
    end)
  end

  # Pellet is simply a coordinate pair
  defp draw_object(graph, :pellet, {x, y}) do
    draw_tile(graph, x, y, fill: :orange)
  end

  # Snake's body is a list of coordinate pairs
  defp draw_object(graph, :snake, %{body: snake}) do
    Enum.reduce(snake, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :blue)
    end)
  end

  # Draw tiles as rounded rectangles to look nice
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    graph |> rrect({@tile_size, @tile_size, @tile_radius}, tile_opts)
  end
end
