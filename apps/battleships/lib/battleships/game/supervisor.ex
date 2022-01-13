defmodule Battleships.Game.Supervisor do
  @moduledoc """
  Supervisor responsible for game area
  """
  use Supervisor

  @spec start_link(any) :: Supervisor.on_start()
  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      Battleships.Game.BattleRepository,
      Battleships.Game.BoardRepository
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
