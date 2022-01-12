defmodule Battleships.SingleBattleTest do
  use ExUnit.Case, asyc: false

  alias Battleships.Game
  alias Battleships.Game.BattleRepository
  alias Battleships.Game.BoardRepository

  setup do
    battle_repo_mock = Application.get_env(:battleships, :battle_repository)
    board_repo_mock = Application.get_env(:battleships, :board_repository)

    Application.put_env(:battleships, :battle_repository, BattleRepository)
    Application.put_env(:battleships, :board_repository, BoardRepository)

    on_exit(fn ->
      Application.put_env(:battleships, :battle_repository, battle_repo_mock)
      Application.put_env(:battleships, :board_repository, board_repo_mock)
    end)
  end

  test "single match run" do
    battle_id = "integration-battle-1"
    player_one_id = "integration-player-1-id"
    player_two_id = "integration-player-2-id"

    # [ONE][WHEN] Battle is initiated
    Game.init_battle(battle_id, player_one_id)

    # [THEN] Battle & board are visible in repository
    {:ok, battle_step_one} = BattleRepository.get_battle(battle_id)
    assert battle_step_one.state == :setup
    assert battle_step_one.battle_id == battle_id
    assert battle_step_one.player_one_id == player_one_id
    assert battle_step_one.player_two_id == nil

    {:ok, board_one_step_one} = BoardRepository.get_board(battle_id, player_one_id)
    assert board_one_step_one.state == :initial
    assert board_one_step_one.player_id == player_one_id
    assert board_one_step_one.ships == []

    # [THEN] No board for second player yet
    assert {:error, :not_found} = BoardRepository.get_board(battle_id, player_two_id)

    # [TWO][WHEN] Player joins battle
    Game.join_battle(battle_id, player_two_id)

    # [THEN] Battle & boards are updated
    {:ok, battle_step_two} = BattleRepository.get_battle(battle_id)
    assert battle_step_two.state == :setup
    assert battle_step_two.battle_id == battle_id
    assert battle_step_two.player_one_id == player_one_id
    assert battle_step_two.player_two_id == player_two_id

    {:ok, board_one_step_two} = BoardRepository.get_board(battle_id, player_two_id)
    assert board_one_step_two.state == :initial
    assert board_one_step_two.player_id == player_two_id
    assert board_one_step_two.ships == []

    # [THREE][WHEN] Player one adds all ships
    Enum.map(
      [
        {1, 1, 5, :vertical},
        {1, 2, 4, :vertical},
        {1, 3, 3, :vertical},
        {1, 4, 2, :vertical},
        {1, 5, 2, :vertical},
        {1, 6, 1, :vertical},
        {1, 7, 1, :vertical}
      ],
      fn {x, y, size, orientation} ->
        Game.add_ship(battle_id, player_one_id, {x, y}, size, orientation)
      end
    )

    # [THEN] Battle is not ready yet
    {:ok, battle_step_three} = BattleRepository.get_battle(battle_id)
    assert battle_step_three.state == :setup
    assert battle_step_three.battle_id == battle_id
    assert battle_step_three.player_one_id == player_one_id
    assert battle_step_three.player_two_id == player_two_id

    # [THEN] Player one board is ready
    {:ok, board_one_step_three} = BoardRepository.get_board(battle_id, player_one_id)
    assert board_one_step_three.state == :ready
    assert board_one_step_three.player_id == player_one_id
    assert length(board_one_step_three.ships) == 7

    # [THEN] Player two board is empty
    {:ok, board_two_step_three} = BoardRepository.get_board(battle_id, player_two_id)
    assert board_two_step_three.state == :initial
    assert board_two_step_three.player_id == player_two_id
    assert board_two_step_three.ships == []

    # [FOUR][WHEN] Player two adds all ships
    Enum.map(
      [
        {1, 1, 5, :horizontal},
        {1, 2, 4, :horizontal},
        {1, 3, 3, :horizontal},
        {1, 4, 2, :horizontal},
        {1, 5, 2, :horizontal},
        {1, 6, 1, :horizontal},
        {1, 7, 1, :horizontal}
      ],
      fn {y, x, size, orientation} ->
        Game.add_ship(battle_id, player_two_id, {x, y}, size, orientation)
      end
    )

    # [THEN] Battle is not ready yet
    {:ok, battle_step_four} = BattleRepository.get_battle(battle_id)
    assert battle_step_four.state == :ongoing
    assert battle_step_four.battle_id == battle_id
    assert battle_step_four.player_one_id == player_one_id
    assert battle_step_four.player_two_id == player_two_id

    # [THEN] Player one board is ready
    {:ok, board_one_step_four} = BoardRepository.get_board(battle_id, player_one_id)
    assert board_one_step_four.state == :ready
    assert board_one_step_four.player_id == player_one_id
    assert length(board_one_step_four.ships) == 7

    # [THEN] Player two board is empty
    {:ok, board_two_step_four} = BoardRepository.get_board(battle_id, player_two_id)
    assert board_two_step_four.state == :ready
    assert board_two_step_four.player_id == player_two_id
    assert length(board_two_step_four.ships) == 7

    # [FIVE][WHEN] Player two makes a first shot
    result = Game.play_turn(battle_id, player_two_id, {1, 1})

    # [THEN] Error is returned
    assert {:error, :another_player_turn} = result

    # [THEN] Player one board is not updated
    {:ok, board_one_step_five} = BoardRepository.get_board(battle_id, player_one_id)
    assert board_one_step_four == board_one_step_five

    # [SIX][WHEN] Player one makes a first shot
    Game.play_turn(battle_id, player_one_id, {1, 1})

    # [THEN] Battle is ongoing & turn is changed
    {:ok, battle_step_six} = BattleRepository.get_battle(battle_id)

    assert battle_step_six.state == :ongoing
    assert battle_step_six.turn == 1

    # [THEN] Player two board ship was hitted
    {:ok, board_two_step_six} = BoardRepository.get_board(battle_id, player_two_id)
    assert Map.get(board_two_step_six.grid.coords, {1, 1}) == "*"

    # [SEVEN][WHEN] Player two makes a shot
    Game.play_turn(battle_id, player_two_id, {9, 9})

    # [THEN] Battle is ongoing & turn is changed
    {:ok, battle_step_seven} = BattleRepository.get_battle(battle_id)

    assert battle_step_seven.state == :ongoing
    assert battle_step_seven.turn == 2

    # [THEN] Player two board ship was hitted
    {:ok, board_two_step_seven} = BoardRepository.get_board(battle_id, player_one_id)
    assert Map.get(board_two_step_seven.grid.coords, {9, 9}) == "0"

    # [EIGHT][WHEN] Player one will destroy all player two ships
    Enum.map(
      [
        # Size one ships - ship one
        {player_one_id, {7, 1}},
        {player_two_id, {1, 1}},
        # Size one ships - ship two
        {player_one_id, {6, 1}},
        {player_two_id, {2, 2}},
        # Size two ships - ship one
        {player_one_id, {5, 1}},
        {player_two_id, {3, 3}},
        {player_one_id, {5, 2}},
        {player_two_id, {4, 4}},
        # Size two ships - ship two
        {player_one_id, {4, 1}},
        {player_two_id, {5, 5}},
        {player_one_id, {4, 2}},
        {player_two_id, {6, 6}},
        # Size three ship
        {player_one_id, {3, 1}},
        {player_two_id, {7, 7}},
        {player_one_id, {3, 2}},
        {player_two_id, {8, 8}},
        {player_one_id, {3, 3}},
        {player_two_id, {9, 9}},
        # Size four ship
        {player_one_id, {2, 1}},
        {player_two_id, {1, 2}},
        {player_one_id, {2, 2}},
        {player_two_id, {1, 3}},
        {player_one_id, {2, 3}},
        {player_two_id, {1, 4}},
        {player_one_id, {2, 4}},
        {player_two_id, {1, 5}},
        # Size five ship
        {player_one_id, {1, 1}},
        {player_two_id, {2, 1}},
        {player_one_id, {1, 2}},
        {player_two_id, {2, 2}},
        {player_one_id, {1, 3}},
        {player_two_id, {2, 3}},
        {player_one_id, {1, 4}},
        {player_two_id, {2, 4}},
        {player_one_id, {1, 5}}
      ],
      fn {player_id, hit_coords} ->
        {:ok, _} = Game.play_turn(battle_id, player_id, hit_coords)
      end
    )

    # [THEN] Battle is ended
    {:ok, battle_step_eight} = BattleRepository.get_battle(battle_id)

    assert battle_step_eight.state == :finished
    assert battle_step_eight.turn == 37
    assert battle_step_eight.winner == :player_one

    # [WHEN] Player two shots
    result = Game.play_turn(battle_id, player_two_id, {1,1})

    # [THEN] Match is already finished
    assert {:error, :battle_already_finished} == result
  end
end
