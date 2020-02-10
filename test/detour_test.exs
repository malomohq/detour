defmodule DetourTest do
  use ExUnit.Case, async: true

  describe "open/0" do
    test "uses an open port" do
      assert detour = %Detour{} = Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: "localhost"])

      messages = Detour.Server.all(detour.pid)

      assert message in messages
    end
  end

  describe "open/1" do
    test "can specify a port" do
      assert detour = %Detour{} = Detour.open(port: 2525)

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: "localhost"])

      messages = Detour.Server.all(detour.pid)

      assert message in messages

      Detour.shutdown(detour)
    end
  end

  describe "shutdown/1" do
    test "stops a server", tags do
      id = to_string(Map.get(tags, :line))

      supervisor = Module.concat([Detour.Supervisor, id])

      { :ok, _pid } = Detour.Supervisor.start_link([name: supervisor])

      detour = Detour.open([supervisor: supervisor])

      assert %{ workers: 1 } = DynamicSupervisor.count_children(supervisor)

      assert :ok = Detour.shutdown(detour, [supervisor: supervisor])

      assert %{ workers: 0 } = DynamicSupervisor.count_children(supervisor)
    end
  end
end
