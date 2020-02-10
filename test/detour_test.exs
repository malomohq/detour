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
      assert detour = %Detour{} = Detour.open(2525)

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: "localhost"])

      messages = Detour.Server.all(detour.pid)

      assert message in messages
    end
  end
end
