defmodule Battleships.Game.BoardTest do
  use ExUnit.Case, asyc: true

  alias Battleships.Game.Board
  alias Battleships.Game.Board.Grid
  alias Battleships.Game.Ship

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

  describe "add_ship/2" do
    setup do
      board = Board.init("game_1", "player_1")

      {:ok, %{board: board}}
    end

    test "allows to add a ship to board", %{board: board} do
      ship = Ship.init(1, 1, 2, :vertical)

      {:ok, new_board} = Board.add_ship(board, ship)

      assert [ship] == new_board.ships
      assert ">" == Map.fetch!(new_board.grid.coords, {1, 1})
      assert ">" == Map.fetch!(new_board.grid.coords, {2, 1})
    end

    test "allows to add a many ships to board", %{board: board} do
      ship_1 = Ship.init(1, 1, 1, :vertical)
      ship_2 = Ship.init(2, 2, 1, :vertical)

      {:ok, board} = Board.add_ship(board, ship_1)
      {:ok, final_board} = Board.add_ship(board, ship_2)

      assert Enum.sort([ship_1, ship_2]) == Enum.sort(final_board.ships)
      assert ">" == Map.fetch!(final_board.grid.coords, {1, 1})
      assert ">" == Map.fetch!(final_board.grid.coords, {2, 2})
    end

    test "returns error when all ships are placed", %{board: board} do
      ship = Ship.init(1, 1, 1, :vertical)
      board = %Board{board | ships: [ship, ship, ship, ship, ship, ship, ship]}

      assert {:error, :all_ships_ready} == Board.add_ship(board, ship)
    end

    test "returns error when uniq ship is placed", %{board: board} do
      ship_1 = Ship.init(1, 1, 5, :vertical)
      ship_2 = Ship.init(2, 2, 5, :vertical)

      board = %Board{board | ships: [ship_1]}

      assert {:error, :ship_already_placed} == Board.add_ship(board, ship_2)
    end

    test "returns error when double ships are placed", %{board: board} do
      ship_1 = Ship.init(1, 1, 1, :vertical)
      ship_2 = Ship.init(2, 2, 1, :vertical)
      ship_3 = Ship.init(3, 3, 1, :vertical)

      board = %Board{board | ships: [ship_1, ship_2]}

      assert {:error, :ship_already_placed} == Board.add_ship(board, ship_3)
    end

    test "returns error when ship placed in invalid coords", %{board: board} do
      ship = Ship.init(6, 6, 5, :vertical)

      assert {:error, :invalid_cords} == Board.add_ship(board, ship)
    end

    test "returns error when ships are overlapping", %{board: board} do
      ship = Ship.init(1, 1, 2, :vertical)

      grid = board.grid
      new_coords = Map.replace!(grid.coords, {1, 1}, ">")
      board = %Board{board | grid: %{grid | coords: new_coords}}

      assert {:error, :ship_already_placed_on_coords} == Board.add_ship(board, ship)
    end
  end

  describe "shot/2" do
    setup do
      ship = Ship.init(1, 1, 2, :vertical)
      {:ok, board} = Board.init("game_1", "player_1") |> Board.add_ship(ship)

      {:ok, %{board: board}}
    end

    test "marks a filed as * when hitted", %{board: board} do
      point = {1, 1}
      %Board{grid: grid} = Board.shot(board, {1, 1})
      grid_coords = grid.coords

      assert "*" == Map.fetch!(grid_coords, point)
    end

    test "marks a filed as 0 when missed", %{board: board} do
      point = {2, 2}
      %Board{grid: grid} = Board.shot(board, {2, 2})
      grid_coords = grid.coords

      assert "0" == Map.fetch!(grid_coords, point)
    end

    test "leaves field as * when hitted twice", %{board: board} do
      point = {1, 1}

      %Board{grid: grid} = board |> Board.shot(point) |> Board.shot(point)
      grid_coords = grid.coords

      assert "*" == Map.fetch!(grid_coords, point)
    end
  end

  describe "defeated?1" do
    setup do
      ship = Ship.init(1, 1, 2, :vertical)
      {:ok, board} = Board.init("game_1", "player_1") |> Board.add_ship(ship)

      {:ok, %{board: board}}
    end

    test "returns true once all ships has been destroyed", %{board: board} do
      new_board = board |> Board.shot({1, 1}) |> Board.shot({2, 1})

      assert Board.defeated?(new_board)
    end

    test "returns false once some ships are still floating", %{board: board} do
      new_board = board |> Board.shot({1, 1})

      refute Board.defeated?(new_board)
    end

    test "returns result when multiple ships placed", %{board: board} do
      ship = Ship.init(2, 2, 1, :vertical)
      {:ok, board} = Board.add_ship(board, ship)
      new_board = board |> Board.shot({1, 1}) |> Board.shot({2, 1}) |> Board.shot({2, 2})

      assert Board.defeated?(new_board)
    end
  end
end
