defmodule Battleships.Game.GameTest do
  use ExUnit.Case, asyc: false
  import Hammox

  alias Battleships.Game.Battle
  alias Battleships.Game.Board
  alias Battleships.Game.Ship
  alias Battleships.Game

  setup :set_mox_global
  setup :verify_on_exit!

  describe "init_battle/2" do
    test "starts new battle & create first player board" do
      battle_id = "battle_id"
      player_id = "player_id"

      battle = Battle.init(battle_id, player_id)
      board = Board.init(battle_id, player_id)

      expect_create_battle(battle_id, player_id, {:ok, battle})
      expect_create_board(battle_id, player_id, {:ok, board})

      {:ok, result} = Game.init_battle(battle_id, player_id)

      assert battle == result
    end

    test "returns error when battle already started" do
      battle_id = "battle_id"
      player_id = "player_id"

      expect_create_battle(battle_id, player_id, {:error, :already_exists})

      assert {:error, :battle_already_exists} == Game.init_battle(battle_id, player_id)
    end

    test "returns error when board already started" do
      battle_id = "battle_id"
      player_id = "player_id"

      battle = Battle.init(battle_id, player_id)

      expect_create_battle(battle_id, player_id, {:ok, battle})
      expect_create_board(battle_id, player_id, {:error, :already_exists})

      assert {:error, :board_already_exists} == Game.init_battle(battle_id, player_id)
    end

    @tag skip: true
    test "drops battle if board creation failed" do
    end
  end

  describe "join_battle/2" do
    test "creates new player board and assigns it to battle" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"

      init_battle = Battle.init(battle_id, player_one_id)
      new_player_board = Board.init(battle_id, player_one_id)
      {:ok, updated_battle} = Battle.add_player(init_battle, player_two_id)

      expect_get_battle(battle_id, {:ok, init_battle})
      expect_create_board(battle_id, player_two_id, {:ok, new_player_board})
      expect_update_battle(updated_battle, {:ok, updated_battle})

      {:ok, result} = Game.join_battle(battle_id, player_two_id)

      assert result == updated_battle
    end

    test "returns error once player already in battle" do
      battle_id = "battle_id"
      player_id = "player_id"

      init_battle = Battle.init(battle_id, player_id)
      expect_get_battle(battle_id, {:ok, init_battle})

      assert {:error, :player_already_in_battle} == Game.join_battle(battle_id, player_id)
    end

    test "returns error when battle does not exists" do
      battle_id = "battle_id"
      player_two_id = "player_two_id"

      expect_get_battle(battle_id, {:error, :not_found})

      assert {:error, :battle_not_found} = Game.join_battle(battle_id, player_two_id)
    end

    test "returns error when battle already full" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"

      init_battle = Battle.init(battle_id, player_one_id)
      {:ok, updated_battle} = Battle.add_player(init_battle, player_two_id)
      new_player_board = Board.init(battle_id, player_one_id)

      expect_get_battle(battle_id, {:ok, updated_battle})
      expect_create_board(battle_id, player_two_id, {:ok, new_player_board})

      assert {:error, :battle_already_full} = Game.join_battle(battle_id, player_two_id)
    end

    test "returns error when board already exists" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"

      init_battle = Battle.init(battle_id, player_one_id)

      expect_get_battle(battle_id, {:ok, init_battle})
      expect_create_board(battle_id, player_two_id, {:error, :already_exists})

      assert {:error, :board_already_exists} = Game.join_battle(battle_id, player_two_id)
    end

    @tag skip: true
    test "drops board if battle already full" do
    end
  end

  describe "add_ship/5" do
    test "adds ship to player board" do
      battle_id = "battle_id"
      player_id = "player_id"

      init_battle = Battle.init(battle_id, player_id)
      init_board = Board.init(battle_id, player_id)
      init_ship = Ship.init(1, 1, 1, :vertical)

      {:ok, board_with_ship} = Board.add_ship(init_board, init_ship)

      expect_get_battle(battle_id, {:ok, init_battle})
      expect_get_board(battle_id, player_id, {:ok, init_board})
      expect_update_board(board_with_ship, {:ok, board_with_ship})

      {:ok, updated_board} = Game.add_ship(battle_id, player_id, {1, 1}, 1, :vertical)

      assert updated_board == board_with_ship
    end

    test "once both boards are ready updates state to ongoing" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"
      ship = Ship.init(3, 3, 1, :vertical)
      init_ship = Ship.init(1, 1, 1, :vertical)

      init_battle = Battle.init(battle_id, player_one_id)
      battle_with_players = %Battle{init_battle | player_two_id: player_two_id}
      ongoing_battle = Battle.set_ongoing(battle_with_players)

      init_board_one = Board.init(battle_id, player_one_id)

      init_board_one_with_ships = %Board{
        init_board_one
        | ships: [ship, ship, ship, ship, ship, ship]
      }

      {:ok, board_one_with_ship} = Board.add_ship(init_board_one_with_ships, init_ship)
      ready_board_one = %Board{board_one_with_ship | state: :ready}

      init_board_two = Board.init(battle_id, player_two_id)
      read_board_two = %Board{init_board_two | state: :ready}

      expect_get_battle(battle_id, {:ok, battle_with_players})
      expect_get_board(battle_id, player_one_id, {:ok, init_board_one_with_ships})
      expect_update_board(ready_board_one, {:ok, ready_board_one})
      expect_get_board(battle_id, player_two_id, {:ok, read_board_two})
      expect_update_battle(ongoing_battle, {:ok, ongoing_battle})

      {:ok, updated_board} = Game.add_ship(battle_id, player_one_id, {1, 1}, 1, :vertical)

      assert updated_board == ready_board_one
    end

    test "returns error when battle not found" do
      battle_id = "battle_id"
      player_id = "player_id"

      expect_get_battle(battle_id, {:error, :not_found})

      assert {:error, :battle_not_found} ==
               Game.add_ship(battle_id, player_id, {1, 1}, 1, :vertical)
    end

    test "returns error when board not found" do
      battle_id = "battle_id"
      player_id = "player_id"

      init_battle = Battle.init(battle_id, player_id)

      expect_get_battle(battle_id, {:ok, init_battle})
      expect_get_board(battle_id, player_id, {:error, :not_found})

      assert {:error, :board_not_found} ==
               Game.add_ship(battle_id, player_id, {1, 1}, 1, :vertical)
    end

    test "returns error when ship cords are invalid" do
      battle_id = "battle_id"
      player_id = "player_id"

      init_battle = Battle.init(battle_id, player_id)
      init_board = Board.init(battle_id, player_id)

      expect_get_battle(battle_id, {:ok, init_battle})
      expect_get_board(battle_id, player_id, {:ok, init_board})

      assert {:error, :invalid_cords} ==
               Game.add_ship(battle_id, player_id, {11, 11}, 1, :vertical)
    end
  end

  describe "play_turn/3" do
    test "plays a single player turn" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"
      ship = Ship.init(2, 2, 2, :vertical)

      init_battle = Battle.init(battle_id, player_one_id)
      {:ok, updated_battle} = Battle.add_player(init_battle, player_two_id)
      player_two_board = Board.init(battle_id, player_two_id)
      {:ok, player_two_board_with_ship} = Board.add_ship(player_two_board, ship)

      ongoing_battle = %Battle{updated_battle | state: :ongoing}
      hitted_board = Board.shot(player_two_board_with_ship, {1, 1})
      next_turn_battle = Battle.next_turn(ongoing_battle)

      expect_get_battle(battle_id, {:ok, ongoing_battle})
      expect_get_board(battle_id, player_two_id, {:ok, player_two_board_with_ship})
      expect_update_board(hitted_board, {:ok, hitted_board})
      expect_update_battle(next_turn_battle, {:ok, next_turn_battle})

      assert {:ok, next_turn_battle} == Game.play_turn(battle_id, player_one_id, {1, 1})
    end

    test "returns error when battle not ready" do
      battle_id = "battle_id"
      player_id = "player_id"

      expect_get_battle(battle_id, {:error, :not_found})

      assert {:error, :battle_not_found} == Game.play_turn(battle_id, player_id, {1, 1})
    end

    test "returns error one battle is not ready" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"

      init_battle = Battle.init(battle_id, player_one_id)

      expect_get_battle(battle_id, {:ok, init_battle})

      assert {:error, :battle_not_ready} == Game.play_turn(battle_id, player_two_id, {1, 1})
    end

    test "returns error when its not a player turn" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"

      init_battle = Battle.init(battle_id, player_one_id)
      {:ok, updated_battle} = Battle.add_player(init_battle, player_two_id)
      ongoing_battle = %Battle{updated_battle | state: :ongoing}

      expect_get_battle(battle_id, {:ok, ongoing_battle})

      assert {:error, :another_player_turn} == Game.play_turn(battle_id, player_two_id, {1, 1})
    end

    test "returns error when enemy board not found" do
      battle_id = "battle_id"
      player_one_id = "player_one_id"
      player_two_id = "player_two_id"

      init_battle = Battle.init(battle_id, player_one_id)
      {:ok, updated_battle} = Battle.add_player(init_battle, player_two_id)
      ongoing_battle = %Battle{updated_battle | state: :ongoing}

      expect_get_battle(battle_id, {:ok, ongoing_battle})
      expect_get_board(battle_id, player_two_id, {:error, :not_found})

      assert {:error, :board_not_found} == Game.play_turn(battle_id, player_one_id, {1, 1})
    end
  end

  def expect_create_battle(expected_battle_id, expected_player_id, result) do
    expect(BattleRepositoryMock, :create_battle, fn battle ->
      assert expected_battle_id == battle.battle_id
      assert expected_player_id == battle.player_one_id

      result
    end)
  end

  defp expect_get_battle(expected_battle_id, result) do
    expect(BattleRepositoryMock, :get_battle, fn battle_id ->
      assert expected_battle_id == battle_id

      result
    end)
  end

  def expect_update_battle(expected_battle, result) do
    expect(BattleRepositoryMock, :update_battle, fn battle ->
      assert expected_battle == battle

      result
    end)
  end

  def expect_create_board(expected_battle_id, expected_player_id, result) do
    expect(BoardRepositoryMock, :create_board, fn board ->
      assert expected_battle_id == board.battle_id
      assert expected_player_id == board.player_id

      result
    end)
  end

  defp expect_get_board(expected_battle_id, expected_player_id, result) do
    expect(BoardRepositoryMock, :get_board, fn battle_id, player_id ->
      assert expected_battle_id == battle_id
      assert expected_player_id == player_id

      result
    end)
  end

  def expect_update_board(expected_board, result) do
    expect(BoardRepositoryMock, :update_board, fn board ->
      assert expected_board == board

      result
    end)
  end
end
