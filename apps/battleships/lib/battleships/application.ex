defmodule Battleships.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Battleships.PubSub}
      # Start a worker by calling: Battleships.Worker.start_link(arg)
      # {Battleships.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Battleships.Supervisor)
  end
end
