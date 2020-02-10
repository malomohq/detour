defmodule Detour.Session do
  @behaviour :gen_smtp_server_session

  def init(hostname, _session_count, _address, opts) do
    banner = [hostname, " ESMTP"]

    state = %{ server: Keyword.get(opts, :server) }

    { :ok, banner, state }
  end

  @impl true
  def code_change(_old, state, _extra) do
    { :ok, state }
  end

  @impl true
  def handle_DATA(from, to, body, state) do
    server = Map.get(state, :server)

    :ok = Detour.Server.push(server, { from, to, body })

    { :ok, 'OK', state }
  end

  @impl true
  def handle_EHLO(_hostname, extensions, state) do
    { :ok, extensions, state }
  end

  @impl true
  def handle_HELO(_hostname, state) do
    { :ok, state }
  end

  @impl true
  def handle_MAIL(_from, state) do
    { :ok, state }
  end

  @impl true
  def handle_MAIL_extension(_extension, state) do
    { :ok, state }
  end

  @impl true
  def handle_other(verb, _args, state) do
    { ["500 Error: command not recognized : '", verb, "'"], state }
  end

  @impl true
  def handle_RCPT(_to, state) do
    { :ok, state }
  end

  @impl true
  def handle_RCPT_extension(_estension, state) do
    { :ok, state }
  end

  @impl true
  def handle_VRFY(address, state) do
    { :ok, address, state }
  end

  @impl true
  def handle_RSET(state) do
    state
  end

  def terminate(reason, state) do
    { :ok, reason, state }
  end
end
