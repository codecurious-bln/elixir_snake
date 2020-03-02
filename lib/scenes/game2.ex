# Game at the end of Chapter 2
defmodule Snake.Scene.Game2 do
  use Scenic.Scene

  import Scenic.Primitives, only: [rounded_rectangle: 3]

  alias Scenic.ViewPort
  alias Scenic.Graph

  @graph Graph.build(clear_color: :dark_sea_green)
  @tile_size 32
  @tile_radius 8

  def init(_arg, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    number_of_columns = div(vp_width, @tile_size)
    number_of_rows = div(vp_height, @tile_size)

    state = %{
      width: number_of_columns,
      height: number_of_rows
    }

    snake = %{body: [{9, 9}, {10, 9}, {11, 9}]}

    graph = draw_object(@graph, snake)

    {:ok, state, push: graph}
  end

  defp draw_object(graph, %{body: snake}) do
    Enum.reduce(snake, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :dark_slate_gray)
    end)
  end

  # draw tiles as rounded rectangles to look nice
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :black, translate: {x * @tile_size, y * @tile_size}], opts)
    rounded_rectangle(graph, {@tile_size, @tile_size, @tile_radius}, tile_opts)
  end
end
