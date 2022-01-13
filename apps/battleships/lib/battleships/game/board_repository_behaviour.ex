defmodule Battleships.Game.BoardRepositoryBehaviour do
  @moduledoc """
  Behaviour for board repository
  """
  alias Battleships.Game.Board

  @callback create_board(Board.t()) :: {:ok, Board.t()} | {:error, :already_exists}
  @callback update_board(Board.t()) :: {:ok, Board.t()} | {:error, :not_found}
  @callback get_board(String.t(), String.t()) :: {:ok, Board.t()} | {:error, :not_found}
end
