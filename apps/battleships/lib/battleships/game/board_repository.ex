defmodule Battleships.Game.BoardRepository do
  @moduledoc """
  ETS based board repository
  """
  use GenServer
  @behaviour Battleships.Game.BoardRepositoryBehaviour
  alias Battleships.Game.BoardRepositoryBehaviour

  alias Battleships.Game.Board

  ##################
  ### Client API ###
  ##################

  @spec start_link(any) :: GenServer.on_start()
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl BoardRepositoryBehaviour
  def create_board(board = %Board{}) do
    GenServer.call(__MODULE__, {:create_board, board})
  end

  @impl BoardRepositoryBehaviour
  def update_board(board) do
    GenServer.call(__MODULE__, {:update_board, board})
  end

  @impl BoardRepositoryBehaviour
  def get_board(battle_id, player_id) do
    battle_id
    |> board_id(player_id)
    |> get_board_by_id()
  end

  #################
  ### Callbacks ###
  #################

  @impl GenServer
  def init(_init_args) do
    board_repository = :ets.new(:board_repository, [:named_table, read_concurrency: true])
    {:ok, %{repository: board_repository}}
  end

  @impl GenServer
  def handle_call({:create_board, board}, _from, state) do
    board_id = board_id(board.battle_id, board.player_id)

    case get_board_by_id(board_id) do
      {:error, :not_found} ->
        insert_or_update_board(board_id, board)
        {:reply, {:ok, board}, state}

      {:ok, _board} ->
        {:reply, {:error, :already_exists}, state}
    end
  end

  @impl GenServer
  def handle_call({:update_board, board}, _from, state) do
    board_id = board_id(board.battle_id, board.player_id)

    case get_board_by_id(board_id) do
      {:error, :not_found} ->
        {:reply, {:error, :not_found}, state}

      {:ok, _board} ->
        insert_or_update_board(board_id, board)
        {:reply, {:ok, board}, state}
    end
  end

  ########################
  ### Helper Functions ###
  ########################

  def insert_or_update_board(board_id, board) do
    :ets.insert(:board_repository, {board_id, board})
  end

  defp get_board_by_id(board_id) do
    case :ets.lookup(:board_repository, board_id) do
      [] -> {:error, :not_found}
      [{_, board}] -> {:ok, board}
    end
  end

  defp board_id(battle_id, player_id) do
    String.to_atom("#{battle_id}-#{player_id}")
  end
end
