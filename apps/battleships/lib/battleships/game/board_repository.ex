defmodule Battleships.Game.BoardRepository do
  @moduledoc """
  ETS based board repository
  """
  use GenServer

  alias Battleships.Game.Board

  ##################
  ### Client API ###
  ##################

  @spec start_link(any) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec add_board(Board.t()) :: {:ok, Board.t()} | {:error, :already_exists}
  def add_board(board = %Board{}) do
    GenServer.call(__MODULE__, {:add_board, board})
  end

  @spec update_board(Board.t()) :: {:ok, Board.t()} | {:error, :not_found}
  def update_board(board) do
    GenServer.call(__MODULE__, {:update_board, board})
  end

  @spec get_board(String.t(), String.t()) :: {:ok, Board.t()} | {:error, :not_found}
  def get_board(game_id, player_id) do
    game_id
    |> board_id(player_id)
    |> get_board_by_id()
  end

  #################
  ### Callbacks ###
  #################

  def init(_init_args) do
    board_repository = :ets.new(:board_repository, [:named_table, read_concurrency: true])
    {:ok, %{repository: board_repository}}
  end

  def handle_call({:add_board, board}, _from, state) do
    board_id = board_id(board.game_id, board.player_id)

    case get_board_by_id(board_id) do
      {:error, :not_found} ->
        :ets.insert(:board_repository, {board_id, board})
        {:reply, {:ok, board}, state}

      {:ok, _board} ->
        {:reply, {:error, :already_exists}, state}
    end
  end

  def handle_call({:update_board, board}, _from, state) do
    board_id = board_id(board.game_id, board.player_id)

    case get_board_by_id(board_id) do
      {:error, :not_found} ->
        {:reply, {:error, :not_found}, state}

      {:ok, _board} ->
        :ets.insert(:board_repository, {board_id, board})
        {:reply, {:ok, board}, state}
    end
  end

  ########################
  ### Helper Functions ###
  ########################

  defp get_board_by_id(board_id) do
    case :ets.lookup(:board_repository, board_id) do
      [] -> {:error, :not_found}
      [{_, board}] -> {:ok, board}
    end
  end

  defp board_id(game_id, player_id) do
    String.to_atom("#{game_id}-#{player_id}")
  end
end
