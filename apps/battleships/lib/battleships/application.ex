defmodule Battleships.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Battleships.Game.BoardRepository,
      {Phoenix.PubSub, name: Battleships.PubSub}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Battleships.Supervisor)
  end
end
