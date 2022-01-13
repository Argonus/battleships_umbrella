defmodule Battleships.Game.BattleTest do
  use ExUnit.Case, asyc: true

  alias Battleships.Game.Battle

  describe "init/2" do
    test "creates a new battle" do
      assert %Battle{
               battle_id: "game-1",
               player_one_id: "player-1",
               player_two_id: nil,
               state: :setup,
               turn: 0,
               active_player: nil,
               winner: nil
             } == Battle.init("game-1", "player-1")
    end
  end

  describe "add_player/2" do
    setup do
      battle = Battle.init("battle-1", "player-1")
      {:ok, %{battle: battle}}
    end

    test "updates player & active player", %{battle: battle} do
      {:ok, result} = Battle.add_player(battle, "player-2")

      assert "player-2" == result.player_two_id
      assert :player_one == result.active_player
    end

    test "returns error when battle already full", %{battle: battle} do
      battle = %Battle{battle | player_two_id: "another-player"}

      assert {:error, :already_full} == Battle.add_player(battle, "player-2")
    end
  end

  describe "next_turn/1" do
    setup do
      battle = Battle.init("battle-1", "player-1")
      {:ok, %{battle: battle}}
    end

    test "increment turn counter", %{battle: battle} do
      battle = %Battle{battle | active_player: :player_one, turn: 0}

      updated_battle = Battle.next_turn(battle)

      assert 1 == updated_battle.turn
    end

    test "switches active player from one to two", %{battle: battle} do
      battle = %Battle{battle | active_player: :player_one}

      updated_battle = Battle.next_turn(battle)

      assert :player_two == updated_battle.active_player
    end

    test "switches active player from two to one", %{battle: battle} do
      battle = %Battle{battle | active_player: :player_two}

      updated_battle = Battle.next_turn(battle)

      assert :player_one == updated_battle.active_player
    end

    test "raises error when no active player", %{battle: battle} do
      assert_raise FunctionClauseError, fn ->
        Battle.next_turn(battle)
      end
    end
  end

  describe "set_ongoing/1" do
    test "changes status to ongoing" do
      battle = Battle.init("battle-1", "player-1")
      updated_battle = Battle.set_ongoing(battle)

      assert updated_battle.state == :ongoing
    end
  end

  describe "set_finished/1" do
    test "changes status to finished" do
      battle = Battle.init("battle-1", "player-1")
      updated_battle = Battle.set_finished(battle, "player-1")

      assert updated_battle.state == :finished
      assert updated_battle.winner == :player_one
    end
  end
end
