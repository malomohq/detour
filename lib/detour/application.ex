defmodule Detour.Application do
  use Application

  @impl true
  def start(_type, _args) do
    Detour.Supervisor.start_link()
  end
end
