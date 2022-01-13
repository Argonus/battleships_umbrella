defmodule Battleships.Game.BattleRepositoryBehaviour do
  @moduledoc """
  Behaviour for battle repository
  """
  alias Battleships.Game.Battle

  @callback create_battle(Battle.t()) :: {:ok, Battle.t()} | {:error, :already_exists}
  @callback get_battle(String.t()) :: {:ok, Battle.t()} | {:error, :not_found}
  @callback update_battle(Battle.t()) :: {:ok, Battle.t()} | {:error, :not_found}
end
