defmodule Detour.Supervisor do
  use DynamicSupervisor

  #
  # client
  #

  @spec start_link :: DynamicSupervisor.on_start()
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
