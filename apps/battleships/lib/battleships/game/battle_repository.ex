defmodule Battleships.Game.BattleRepository do
  @moduledoc """
  ETS based battle repository
  """
  use GenServer
  alias Battleships.Game.Battle

  ##################
  ### Client API ###
  ##################

  @spec start_link(any) :: GenServer.on_start()
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @spec create_battle(Battle.t()) :: {:ok, Battle.t()} | {:error, :already_exists}
  def create_battle(battle) do
    GenServer.call(__MODULE__, {:create_battle, battle})
  end

  @spec get_battle(String.t()) :: {:ok, Battle.t()} | {:error, :not_found}
  def get_battle(battle_id) do
    get_battle_by_id(battle_id)
  end

  @spec update_battle(Battle.t()) :: {:ok, Battle.t()} | {:error, :not_found}
  def update_battle(battle) do
    GenServer.call(__MODULE__, {:update_battle, battle})
  end

  #################
  ### Callbacks ###
  #################

  @impl true
  def init(_args) do
    board_repository = :ets.new(:battle_repository, [:named_table, read_concurrency: true])
    {:ok, %{repository: board_repository}}
  end

  @impl true
  def handle_call({:create_battle, battle}, _from, state) do
    case get_battle_by_id(battle.battle_id) do
      {:error, :not_found} ->
        insert_or_update_battle(battle)
        {:reply, {:ok, battle}, state}

      {:ok, _battle} ->
        {:reply, {:error, :already_exists}, state}
    end
  end

  @impl true
  def handle_call({:update_battle, battle}, _from, state) do
    case get_battle_by_id(battle.battle_id) do
      {:error, :not_found} ->
        {:reply, {:error, :not_found}, state}

      {:ok, _board} ->
        insert_or_update_battle(battle)
        {:reply, {:ok, battle}, state}
    end
  end

  ########################
  ### Helper Functions ###
  ########################

  defp insert_or_update_battle(battle) do
    :ets.insert(:battle_repository, {battle.battle_id, battle})
  end

  defp get_battle_by_id(battle_id) do
    case :ets.lookup(:battle_repository, battle_id) do
      [] -> {:error, :not_found}
      [{_, battle}] -> {:ok, battle}
    end
  end
end
