defmodule Battleships.Game.Board do
  @moduledoc """
  Game Board
  """

  alias Battleships.Game.Ship

  defmodule Grid do
    @moduledoc """
    Game Board grid
    """
    alias Battleships.Game.Ship

    @water_value "."
    @ship_value ">"

    defstruct [:coords]

    @type t :: %__MODULE__{coords: map}
    @type coords :: {non_neg_integer, non_neg_integer}

    @spec init(integer) :: __MODULE__.t()
    def init(size) do
      coords =
        Enum.reduce(0..(size - 1), %{}, fn x, acc ->
          Enum.reduce(0..(size - 1), acc, fn y, acc2 ->
            Map.put(acc2, {x, y}, @water_value)
          end)
        end)

      %__MODULE__{coords: coords}
    end

    @spec mark_coords(__MODULE__.t(), [coords], :ship) :: __MODULE__.t()
    def mark_coords(grid = %__MODULE__{coords: grid_coords}, coords, :ship) do
      new_grid_coords =
        Enum.reduce(coords, grid_coords, fn point, acc ->
          Map.replace!(acc, point, @ship_value)
        end)

      %__MODULE__{grid | coords: new_grid_coords}
    end

    @spec ship_placed?(__MODULE__.t(), {non_neg_integer, non_neg_integer}) :: boolean
    def ship_placed?(%__MODULE__{coords: grid_cords}, coords) do
      Map.fetch!(grid_cords, coords) == @ship_value
    end
  end

  @size 10
  @ships [5, 4, 3, 2, 2, 1, 1]

  defstruct [:game_id, :player_id, :grid, :ships, :state]

  @type state :: :initial | :ongoing
  @type t :: %__MODULE__{
          player_id: String.t(),
          game_id: String.t(),
          grid: Grid.t(),
          ships: [Ship.t()],
          state: state
        }

  @spec init(String.t(), String.t()) :: __MODULE__.t()
  def init(game_id, player_id) do
    %__MODULE__{
      game_id: game_id,
      player_id: player_id,
      grid: Grid.init(@size),
      ships: [],
      state: :initial
    }
  end

  @type add_ship_errors ::
          :all_ships_ready
          | :ship_already_placed
          | :invalid_cords
          | :ship_already_placed_on_coords
  @spec add_ship(__MODULE__.t(), Ship.t()) :: {:ok, __MODULE__.t()} | {:error, add_ship_errors}
  def add_ship(board = %__MODULE__{ships: prev_ships, grid: prev_grid}, ship) do
    cond do
      length(prev_ships) == length(@ships) ->
        {:error, :all_ships_ready}

      ship_placed?(prev_ships, ship) ->
        {:error, :ship_already_placed}

      invalid_coords?(ship) ->
        {:error, :invalid_cords}

      overlapping_ships?(prev_grid, ship) ->
        {:error, :ship_already_placed_on_coords}

      true ->
        ship_coords = Ship.coords(ship)
        new_grid = Grid.mark_coords(prev_grid, ship_coords, :ship)

        {:ok, %__MODULE__{board | ships: [ship | prev_ships], grid: new_grid}}
    end
  end

  defp ship_placed?(ships, %Ship{size: size}) when size in [5, 4, 3] do
    Enum.any?(ships, &(&1.size == size))
  end

  defp ship_placed?(ships, %Ship{size: size}), do: Enum.count(ships, &(&1.size == size)) == 2

  # That could be tested on ship level, but as map size could be dynamic in future, I'll leave it here.
  defp invalid_coords?(ship) do
    ship |> Ship.coords() |> Enum.any?(fn {x, y} -> x > @size - 1 || y > @size - 1 end)
  end

  defp overlapping_ships?(grid, ship) do
    Ship.coords(ship) |> Enum.any?(&Grid.ship_placed?(grid, &1))
  end
end
