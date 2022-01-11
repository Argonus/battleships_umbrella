defmodule Battleships.Game.Ship do
  @moduledoc """
  Represents a ship
  """

  defstruct [:x, :y, :size, :orientation]

  @type orientation :: :vertical | :horizontal

  @type t :: %__MODULE__{
          x: integer,
          y: integer,
          size: integer,
          orientation: orientation
        }

  @spec init(non_neg_integer, non_neg_integer, pos_integer, orientation) :: __MODULE__.t()
  def init(x, y, size, orientation)
      when x >= 0 and y >= 0 and size > 0 and orientation in [:vertical, :horizontal] do
    %__MODULE__{
      x: x,
      y: y,
      size: size,
      orientation: orientation
    }
  end
end
