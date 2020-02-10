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
  Starts a Detour server on a randomly assigned open port.
  """
  @spec open ::
          Detour.t()
          | { :error, { :already_started, pid() }
          | { :shutdown, term() } | term() }
  def open do
    { :ok, socket } = :gen_tcp.listen(0, [])

    { :ok, port } = :inet.port(socket)

    :ok = :gen_tcp.close(socket)

    open(port)
  end

  @doc """
  Starts a Detour server using the specified port.
  """
  @spec open(pos_integer) ::
          Detour.t()
          | { :error, { :already_started, pid() }
          | { :shutdown, term() } | term() }
  def open(port) do
    args = [caller: self(), port: port]

    case Detour.Supervisor.start_child(args) do
      { :ok, pid } ->
        detour = %__MODULE__{ pid: pid, port: port }

        Process.put(:__detour__, detour)

        detour
      otherwise ->
        otherwise
    end
  end
end
