defmodule Battleships.Game.Battle do
  @moduledoc """
  Battle is singular game between two players
  """

  defstruct [:battle_id, :player_one_id, :state, :player_two_id, :turn, :active_player, :winner]

  @type t :: %__MODULE__{
          battle_id: String.t(),
          player_one_id: String.t(),
          player_two_id: String.t() | nil,
          state: :setup | :ongoing | :finished,
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
      state: :setup,
      turn: 0,
      active_player: nil,
      winner: nil
    }
  end

  @spec add_player(__MODULE__.t(), String.t()) :: {:ok, __MODULE__.t()} | {:error, :already_full}
  def add_player(battle = %__MODULE__{player_two_id: nil}, player_id) do
    {:ok, %__MODULE__{battle | player_two_id: player_id, active_player: :player_one}}
  end

  def add_player(_, _), do: {:error, :already_full}

  @spec next_turn(__MODULE__.t()) :: __MODULE__.t()
  def next_turn(battle) do
    battle
    |> increment_turn()
    |> toggle_player()
  end

  defp increment_turn(battle = %__MODULE__{turn: turn}), do: %__MODULE__{battle | turn: turn + 1}

  defp toggle_player(battle = %__MODULE__{active_player: :player_one}),
    do: %__MODULE__{battle | active_player: :player_two}

  defp toggle_player(battle = %__MODULE__{active_player: :player_two}),
    do: %__MODULE__{battle | active_player: :player_one}

  @spec set_ongoing(__MODULE__.t()) :: __MODULE__.t()
  def set_ongoing(battle), do: %__MODULE__{battle | state: :ongoing}

  @spec set_finished(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_finished(battle, winner_id) do
    winner = get_winner_atom(battle, winner_id)

    battle
    |> increment_turn()
    |> Map.replace(:state, :finished)
    |> Map.replace(:winner, winner)
  end

  def get_winner_atom(%__MODULE__{player_one_id: winner_id}, winner_id), do: :player_one
  def get_winner_atom(%__MODULE__{player_two_id: winner_id}, winner_id), do: :player_two
end
