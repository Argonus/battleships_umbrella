defmodule Battleships.Game.BattleTest do
  use ExUnit.Case, asyc: true

  alias Battleships.Game.Battle

  describe "init/2" do
    test "creates a new battle" do
      assert %Battle{
               battle_id: "game-1",
               player_one_id: "player-1",
               player_two_id: nil,
               turn: 0,
               active_player: nil,
               winner: nil
             } == Battle.init("game-1", "player-1")
    end
  end
end
