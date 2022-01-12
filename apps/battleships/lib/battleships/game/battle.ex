defmodule Battleships.Game.Battle do
  @moduledoc """
  Battle is singular game between two players
  """

  defstruct [:battle_id, :player_one_id, :player_two_id, :turn, :active_player, :winner]

  @type t :: %__MODULE__{
          battle_id: String.t(),
          player_one_id: String.t(),
          player_two_id: String.t() | nil,
          turn: non_neg_integer,
          active_player: :player_one | :player_two | nil,
          winner: :player_one | :player_two | nil
        }

  @spec init(String.t(), String.t()) :: __MODULE__.t()
  def init(battle_id, creator_id) do
    %__MODULE__{
      battle_id: battle_id,
      player_one_id: creator_id,
      player_two_id: nil,
      turn: 0,
      active_player: nil,
      winner: nil
    }
  end
end
