defmodule Detour.AsseertionsTest do
  use ExUnit.Case, async: true

  import Detour.Assertions

  @relay "localhost"

  describe "assert_message_delivered/3" do
    test "receives a message" do
      detour = Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: @relay])

      { { :detour, :received }, ^message } = assert_message_delivered(message)
    end

    test "does not receive a message" do
      Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      try do
        assert_message_delivered(message)
      rescue
        error in [ExUnit.AssertionError] ->
          failure_message = "Assertion failed, expected to receive message #{inspect(message)} after\n150ms\nReceived 0 messages\n"

          ^failure_message = error.message
      end
    end
  end

  describe "assert_number_of_messages_delivered/3" do
    test "receives the expected number of messages" do
      detour = Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: @relay])

      [{ { :detour, :received }, ^message }] = assert_number_of_messages_delivered(1)
    end

    test "does not receive the expected number of messages" do
      detour = Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: @relay])

      try do
        assert_number_of_messages_delivered(2)
      rescue
        error in [ExUnit.AssertionError] ->
          failure_message = "Asseration failed, expected to receive 2 messages but\nreceived 1 after 150ms\n"

          ^failure_message = error.message
      end
    end
  end

  describe "refute_message_delivered/3" do
    test "does not receive a message" do
      Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      false = refute_message_delivered(message)
    end

    test "receives a message" do
      detour = Detour.open()

      message = { "me@notyou.com", ["you@notme.com"], "HELLO" }

      :gen_smtp_client.send_blocking(message, [port: detour.port, relay: @relay])

      try do
        refute_message_delivered(message)
      rescue
        error in [ExUnit.AssertionError] ->
          failure_message = "Unexpectedly received message {{:detour, :received}, #{inspect(message)}} (which matched ^expected)"

          ^failure_message = error.message
      end
    end
  end
end
