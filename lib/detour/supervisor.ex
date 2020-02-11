defmodule Detour.Supervisor do
  use DynamicSupervisor

  #
  # client
  #

  @spec start_child(Keyword.t()) :: DynamicSupervisor.on_start_child()
  def start_child(opts) do
    supervisor = Keyword.get(opts, :supervisor)

    spec = Map.new()
    spec = Map.put(spec, :id, Detour.Server)
    spec = Map.put(spec, :restart, :transient)
    spec = Map.put(spec, :start, { Detour.Server, :start_link, [opts] })

    DynamicSupervisor.start_child(supervisor, spec)
  end

  @spec start_link(Keyword.t()) :: Supervisor.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)

    DynamicSupervisor.start_link(__MODULE__, :ok, name: name)
  end

  #
  # callbacks
  #

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
