defmodule Battleships.Game.Board do
  @moduledoc """
  Game Board
  """

  defmodule Grid do
    @moduledoc """
    Game Board grid
    """

    @water_value "."

    defstruct [:coords]

    @type t :: %__MODULE__{coords: map}

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
  end

  @size 10

  defstruct [:game_id, :player_id, :grid, :state]

  @type state :: :initial | :ongoing
  @type t :: %__MODULE__{
          player_id: String.t(),
          game_id: String.t(),
          grid: Grid.t(),
          state: state
        }

  @spec init(String.t(), String.t()) :: __MODULE__.t()
  def init(game_id, player_id) do
    %__MODULE__{
      game_id: game_id,
      player_id: player_id,
      grid: Grid.init(@size),
      state: :initial
    }
  end
end
