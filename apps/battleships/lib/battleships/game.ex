defmodule Battleships.Game do
  @moduledoc """
  Basic game logic implementation
  This module can be refactored to state machine on gen server to handle concurrency errors.
  """
  alias Battleships.Game.Battle
  alias Battleships.Game.Board
  alias Battleships.Game.Ship

  # Game types
  @type plain_coords :: {non_neg_integer, non_neg_integer}
  @type ship_orientation :: :vertical | :horizontal

  @type init_errors :: :battle_already_exists | :board_already_exists
  @spec init_battle(String.t(), String.t()) :: {:ok, Battle.t()} | {:error, init_errors}
  def init_battle(battle_id, player_id) do
    with battle <- Battle.init(battle_id, player_id),
         {:battle, {:ok, battle}} <- {:battle, battle_repository().create_battle(battle)},
         board <- Board.init(battle_id, player_id),
         {:board, {:ok, _board}} <- {:board, board_repository().create_board(board)} do
      {:ok, battle}
    else
      {:battle, {:error, :already_exists}} -> {:error, :battle_already_exists}
      {:board, {:error, :already_exists}} -> {:error, :board_already_exists}
    end
  end

  @type join_battle_errors :: :battle_not_found | :battle_already_full | :board_already_exists

  @spec join_battle(String.t(), String.t()) :: {:ok, Battle.t()} | {:error, :battle_already_full}
  def join_battle(battle_id, player_id) do
    with {:battle, {:ok, battle}} <- {:battle, battle_repository().get_battle(battle_id)},
         {:battle, false} <- {:battle, already_in_battle?(battle, player_id)},
         board <- Board.init(battle_id, player_id),
         {:board, {:ok, _board}} <- {:board, board_repository().create_board(board)},
         {:battle, {:ok, battle_with_player}} <- {:battle, Battle.add_player(battle, player_id)},
         {:battle, {:ok, updated_battle}} <-
           {:battle, battle_repository().update_battle(battle_with_player)} do
      {:ok, updated_battle}
    else
      {:battle, true} -> {:error, :player_already_in_battle}
      {:battle, {:error, :not_found}} -> {:error, :battle_not_found}
      {:battle, {:error, :already_full}} -> {:error, :battle_already_full}
      {:board, {:error, :already_exists}} -> {:error, :board_already_exists}
    end
  end

  defp already_in_battle?(%Battle{player_one_id: player_id}, player_id), do: true
  defp already_in_battle?(_, _), do: false

  @type orientation :: Ship.orientation()
  @type add_ship_errors :: :board_not_found | :battle_not_found | Board.add_ship_errors()
  @spec add_ship(String.t(), String.t(), plain_coords, integer, orientation()) :: {:ok, Board.t()}
  def add_ship(battle_id, player_id, {x, y}, ship_size, ship_orientation) do
    with {:battle, {:ok, _battle}} <- {:battle, battle_repository().get_battle(battle_id)},
         {:board, {:ok, board}} <- {:board, board_repository().get_board(battle_id, player_id)},
         ship <- Ship.init(x, y, ship_size, ship_orientation),
         {:ship_board, {:ok, board_with_ship}} <- {:ship_board, Board.add_ship(board, ship)},
         {:board, {:ok, updated_board}} <-
           {:board, board_repository().update_board(board_with_ship)} do
      #      if updated_board.state == :ready && enemy_board.state == :ready do
      #        # Update battle state
      #      end

      {:ok, updated_board}
    else
      {:battle, {:error, :not_found}} -> {:error, :battle_not_found}
      {:board, {:error, :not_found}} -> {:error, :board_not_found}
      {:ship_board, {:error, error}} -> {:error, error}
    end
  end

  @type battle_play_turn_errors ::
          :battle_not_found | :another_player_turn | :battle_not_ready | :battle_already_finished
  @type board_play_turn_errors :: :board_not_found
  @spec play_turn(String.t(), String.t(), plain_coords) ::
          {:ok, Battle.t()} | {:error, battle_play_turn_errors | board_play_turn_errors}
  def play_turn(battle_id, player_id, hit_coords) do
    with {:battle, {:ok, battle}} <- {:battle, battle_repository().get_battle(battle_id)},
         {:battle, {:state, :ongoing}} <- {:battle, {:state, battle.state}},
         {:player_battle, true} <- {:player_battle, player_turn?(battle, player_id)},
         {:player_battle, enemy_id} <- {:player_battle, enemy_player_id(battle, player_id)},
         {:board, {:ok, enemy_board}} <-
           {:board, board_repository().get_board(battle_id, enemy_id)},
         {:board, hitted_enemy_board} <- {:board, Board.shot(enemy_board, hit_coords)},
         {:board, {:ok, _updated_enemy_board}} <-
           {:board, board_repository().update_board(hitted_enemy_board)},
         {:battle, next_turn_battle} <- {:battle, Battle.next_turn(battle)},
         {:battle, {:ok, updated_battle}} <-
           {:battle, battle_repository().update_battle(next_turn_battle)} do
      {:ok, updated_battle}
    else
      {:battle, {:error, :not_found}} -> {:error, :battle_not_found}
      {:battle, {:state, :setup}} -> {:error, :battle_not_ready}
      {:battle, {:state, :finished}} -> {:error, :battle_already_finished}
      {:player_battle, false} -> {:error, :another_player_turn}
      {:board, {:error, :not_found}} -> {:error, :board_not_found}
    end
  end

  defp player_turn?(%Battle{player_one_id: player_id, active_player: :player_one}, player_id),
    do: true

  defp player_turn?(%Battle{player_two_id: player_id, active_player: :player_two}, player_id),
    do: true

  defp player_turn?(_, _), do: false

  defp enemy_player_id(%Battle{player_one_id: enemy_id, player_two_id: player_id}, player_id),
    do: enemy_id

  defp enemy_player_id(%Battle{player_one_id: player_id, player_two_id: enemy_id}, player_id),
    do: enemy_id

  # Repositories
  defp battle_repository, do: Application.get_env(:battleships, :battle_repository)
  defp board_repository, do: Application.get_env(:battleships, :board_repository)
end
