defmodule Battleships.Game.ShipTest do
  use ExUnit.Case, asyc: true

  alias Battleships.Game.Ship

  describe "init/4" do
    test "returns new ship" do
      assert %Ship{
               x: 1,
               y: 0,
               size: 2,
               orientation: :vertical
             } == Ship.init(1, 0, 2, :vertical)
    end

    test "returns error when x is < 0" do
      assert_raise FunctionClauseError, fn ->
        Ship.init(-1, 0, 2, :vertical)
      end
    end

    test "returns error when y is < 0" do
      assert_raise FunctionClauseError, fn ->
        Ship.init(1, -1, 2, :vertical)
      end
    end

    test "returns error when size is < 1" do
      assert_raise FunctionClauseError, fn ->
        Ship.init(0, 0, 0, :vertical)
      end
    end

    test "returns error when orientation is invalid" do
      assert_raise FunctionClauseError, fn ->
        Ship.init(0, 0, 1, :invalid)
      end
    end
  end

  describe "coords/1" do
    test "returns list of coords for vertical ship" do
      ship = Ship.init(0, 0, 2, :vertical)

      assert [{0, 0}, {1, 0}] == Ship.coords(ship)
    end

    test "returns list of coords for horizontal ship" do
      ship = Ship.init(0, 0, 2, :horizontal)

      assert [{0, 0}, {0, 1}] == Ship.coords(ship)
    end
  end
end
