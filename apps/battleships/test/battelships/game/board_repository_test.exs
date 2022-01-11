defmodule Battleships.Game.BoardRepositoryTest do
  use ExUnit.Case, asyc: false

  alias Battleships.Game.Board
  alias Battleships.Game.BoardRepository

  describe "add_board/1" do
    test "adds board to ets storage" do
      board = Board.init("game_1", "player_1")

      assert {:ok, board} == BoardRepository.add_board(board)
    end

    test "returns error when board already exists" do
      board = Board.init("game_2", "player_2")

      assert {:ok, board} == BoardRepository.add_board(board)
      assert {:error, :already_exists} == BoardRepository.add_board(board)
    end
  end

  describe "get_board/2" do
    test "returns board if it exists" do
      board = Board.init("game_3", "player_3")
      {:ok, board} = BoardRepository.add_board(board)
      {:ok, result} = BoardRepository.get_board("game_3", "player_3")

      assert result == board
    end

    test "returns not_found when board does not exists" do
      assert {:error, :not_found} == BoardRepository.get_board("game_4", "player_4")
    end
  end

  describe "update_board/1" do
    test "updates already existing board" do
      board = Board.init("game_5", "player_5")
      {:ok, _board} = BoardRepository.add_board(board)

      updated_board = %Board{board | state: :ongoing}
      {:ok, _board} = BoardRepository.update_board(updated_board)
      {:ok, result} = BoardRepository.get_board("game_5", "player_5")

      assert updated_board == result
    end

    test "returns error when board does not exists" do
      board = Board.init("game_6", "player_6")

      assert {:error, :not_found} == BoardRepository.update_board(board)
    end
  end
end
