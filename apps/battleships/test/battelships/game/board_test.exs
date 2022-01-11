defmodule Battleships.Game.BoardTest do
  use ExUnit.Case, asyc: true

  alias Battleships.Game.Board
  alias Battleships.Game.Board.Grid

  describe "init/2" do
    test "returns empty board with grid" do
      board = Board.init("game_1", "player_1")
      %Grid{coords: grid_coords} = board.grid

      # assert board
      assert "game_1" == board.game_id
      assert "player_1" == board.player_id
      assert :initial == board.state

      # assert grid
      assert 100 == map_size(grid_coords)
      assert ["."] == Map.values(grid_coords) |> Enum.uniq()
    end
  end
end
