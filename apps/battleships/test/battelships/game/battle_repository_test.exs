defmodule Battleships.Game.BattleRepositoryTest do
  use ExUnit.Case, asyc: false

  alias Battleships.Game.Battle
  alias Battleships.Game.BattleRepository

  describe "create_battle/1" do
    test "create new battle" do
      battle = Battle.init("battle_1", "player_1")

      {:ok, result} = BattleRepository.create_battle(battle)

      assert battle == result
    end

    test "returns error when battle already exists" do
      battle = Battle.init("battle_2", "player_2")
      {:ok, _battle} = BattleRepository.create_battle(battle)
      result = BattleRepository.create_battle(battle)

      assert {:error, :already_exists} == result
    end
  end

  describe "get_battle/1" do
    test "returns existing battle" do
      battle = Battle.init("battle_3", "player_3")
      {:ok, _battle} = BattleRepository.create_battle(battle)

      assert {:ok, battle} == BattleRepository.get_battle(battle.battle_id)
    end

    test "returns error when battle not found" do
      assert {:error, :not_found} == BattleRepository.get_battle("non-existing-battle")
    end
  end

  describe "update_battle/1" do
    test "updates existing battle" do
      battle = Battle.init("battle_4", "player_4")
      {:ok, _battle} = BattleRepository.create_battle(battle)

      updated_battle = %Battle{battle | turn: 10_000}

      assert {:ok, updated_battle} == BattleRepository.update_battle(updated_battle)
    end

    test "returns error when battle not found" do
      battle = Battle.init("battle_5", "player_5")
      assert {:error, :not_found} == BattleRepository.update_battle(battle)
    end
  end
end
