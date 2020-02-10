defmodule Detour do
  @type message_t :: { binary, [binary], binary }

  @type t ::
          %__MODULE__{ pid: pid | nil, port: pos_integer }

  defstruct [:pid, :port]

  @doc """
  Returns the detour struct associated with the current process.
  """
  @spec get :: t
  def get do
    Process.get(:__detour__)
  end

  @doc """
  Starts a Detour server.

  You can specify a port by providing a value to the `:port` option. If a port
  isn't provided then a random open port will be used. Note that it is
  preferrable to have Detour assign a port for you. When assigning a static port
  you run into the risk of address conflicts and limits your ability to run
  tests asynchronously.

  Returns a `%Detour{}` struct that will contain the assigned port. You can pass
  this port to your SMTP client with a relay of `localhost` to direct all SMTP
  traffic to Detour.
  """
  @spec open(Keyword.t()) :: t | { :error, term }
  def open(opts \\ []) do
    port = Keyword.get(opts, :port)
    port = do_get_port(port)

    supervisor = Keyword.get(opts, :supervisor, Detour.Supervisor)

    args = opts
    args = Keyword.put(args, :caller, self())
    args = Keyword.put(args, :port, port)
    args = Keyword.put(args, :supervisor, supervisor)

    case Detour.Supervisor.start_child(args) do
      { :ok, pid } ->
        do_when_started(pid, port)
      { :error, { :already_started, pid } } ->
        do_when_started(pid, port)
      otherwise ->
        otherwise
    end
  end

  defp do_get_port(nil) do
    { :ok, socket } = :gen_tcp.listen(0, [])

    { :ok, port } = :inet.port(socket)

    :ok = :gen_tcp.close(socket)

    port
  end

  defp do_get_port(port) do
    port
  end

  defp do_when_started(pid, port) do
    detour = %__MODULE__{ pid: pid, port: port }

    Process.put(:__detour__, detour)

    detour
  end

  @doc """
  Stops a running Detour server.

  Stopping a Detour server will release it's port making it available for
  another process. When providing a port to `open/1` it's important to perform
  a shutdown, otherwise test processes using the same port can conflict.
  """
  @spec shutdown(atom | pid, t) :: :ok | { :error, :not_found }
  def shutdown(supervisor \\ Detour.Supervisor, detour) do
    DynamicSupervisor.terminate_child(supervisor, detour.pid)
  end
end
