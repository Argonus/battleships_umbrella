defmodule Battleships.MatchTest do
  use ExUnit.Case, asyc: false

  setup do
    battle_repo_mock = Application.get_env(:battleships, :battle_repository)
    board_repo_mock = Application.get_env(:battleships, :board_repository)

    Application.put_env(:battleships, :battle_repository, Battleships.Game.BattleRepository)
    Application.put_env(:battleships, :board_repository, Battleships.Game.BoardRepository)

    on_exit(fn ->
      Application.put_env(:battleships, :battle_repository, battle_repo_mock)
      Application.put_env(:battleships, :board_repository, board_repo_mock)
    end)
  end

  test "march run" do
  end
end
