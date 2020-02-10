defmodule Detour.Server do
  use GenServer

  @listen_ip { 127, 0, 0, 1 }

  #
  # client
  #

  @spec all(pid) :: [Detour.message_t()]
  def all(server) do
    GenServer.call(server, :all)
  end

  @spec push(pid, Detour.message_t()) :: :ok
  def push(server, message) do
    GenServer.call(server, { :push, message })
  end

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  #
  # callbacks
  #

  @impl true
  def init(opts) do
    caller = Keyword.get(opts, :caller)

    opts = Keyword.put(opts, :address, @listen_ip)
    opts = Keyword.put(opts, :sessionoptions, [callbackoptions: [server: self()]])
    opts = Keyword.drop(opts, [:caller])

    { :ok, _pid } = :gen_smtp_server.start_link(Detour.Session, [opts])

    { :ok, %{ caller: caller, messages: [] } }
  end

  @impl true
  def handle_call(:all, _from, state) do
    messages = Map.get(state, :messages)

    { :reply, messages, state }
  end

  @impl true
  def handle_call({ :push, message }, _from, state) do
    messages = Map.get(state, :messages)

    messages = messages ++ [message]

    state
    |> Map.get(:caller)
    |> send({ { :detour, :received }, message })

    { :reply, :ok, Map.put(state, :messages, messages) }
  end
end
