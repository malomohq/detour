defmodule Detour.Supervisor do
  use DynamicSupervisor

  #
  # client
  #

  @spec start_child(Keyword.t()) :: DynamicSupervisor.on_start_child()
  def start_child(opts) do
    spec = %{ id: Detour.Server, start: { Detour.Server, :start_link, [opts] } }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @spec start_link :: Supervisor.on_start()
  def start_link do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: Detour.Supervisor)
  end

  #
  # callbacks
  #

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
