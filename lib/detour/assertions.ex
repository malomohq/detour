defmodule Detour.Assertions do
  @moduledoc """
  Assertions used for testing email deliverability.
  """

  import ExUnit.Assertions, only: [flunk: 1]

  @default_timeout 150

  @doc """
  Asserts that a specific message has been delivered within the timeout period,
  specified in milliseconds.

  `timeout` has a default of #{inspect(@default_timeout)} milliseconds.

  The `message` argument must match the pattern `{from, [to], body}`.

  Note that `body` must be the data expected to be received by an SMTP server.
  This is typically an RFC2822 encoded string.

  ## Examples

      assert_message_delivered {"me@notyou.com", ["you@notme.com"], message}
  """
  defmacro assert_message_delivered(message, timeout \\ @default_timeout, failure_message \\ nil) do
    quote bind_quoted: [failure_message: failure_message, message: message, timeout: timeout] do
      import ExUnit.Assertions

      expected = { { :detour, :received }, message }

      assert_receive(^expected, timeout, failure_message || Detour.Assertions.flunk_message_delivered(message, timeout))
    end
  end

  @doc """
  Asserts that a number of messages have been delivered within the timeout
  period, specified in milliseconds.

  `timeout` has a default of #{inspect(@default_timeout)} milliseconds.

  ## Example

      assert_number_of_messages_delivered 3
  """
  defmacro assert_number_of_messages_delivered(expected, timeout \\ @default_timeout, failure_message \\ nil) do
    quote bind_quoted: [expected: expected, failure_message: failure_message, timeout: timeout] do
      import ExUnit.Assertions

      for n <- 1..expected do
        assert_receive({ { :detour, :received }, _message }, timeout, failure_message || Detour.Assertions.flunk_number_of_messages_delivered(expected, timeout))
      end
    end
  end

  @doc """
  Asserts that a message has not been delivered within the timeout period,
  specified in milliseconds.

  `timeout` has a default of #{inspect(@default_timeout)} milliseconds.

  The `message` argument must match the pattern `{from, [to], body}`.

  Note that `body` must be the data expected to be received by an SMTP server.
  This is typically an RFC2822 encoded string.

  ## Example

      refute_message_delivered {"me@notyou.com", ["you@notme.com"], message}
  """
  defmacro refute_message_delivered(message, timeout \\ @default_timeout, failure_message \\ nil) do
    quote bind_quoted: [failure_message: failure_message, message: message, timeout: timeout] do
      import ExUnit.Assertions

      expected = { { :detour, :received }, message }

      refute_receive(^expected, timeout)
    end
  end

  @doc false
  @spec flunk_message_delivered(Detour.message_t(), pos_integer) :: no_return
  def flunk_message_delivered(message, timeout) do
    detour = Detour.get()

    messages = Detour.Server.all(detour.pid)

    received = length(messages)

    flunk(
      """
      Assertion failed, expected to receive message #{inspect(message)} after
      #{inspect(timeout)}ms
      Received #{inspect(received)} messages
      """
    )
  end

  @doc false
  @spec flunk_message_not_delivered(Detour.message_t(), pos_integer) :: no_return
  def flunk_message_not_delivered(message, timeout) do
    flunk(
      """
      Assertion failed, expected to not receive message #{inspect(message)}
      after #{inspect(timeout)}ms
      """
    )
  end

  @doc false
  @spec flunk_number_of_messages_delivered(non_neg_integer, pos_integer) :: no_return
  def flunk_number_of_messages_delivered(expected, timeout) do
    detour = Detour.get()

    messages = Detour.Server.all(detour.pid)

    received = length(messages)

    flunk(
      """
      Asseration failed, expected to receive #{inspect(expected)} messages but
      received #{inspect(received)} after #{inspect(timeout)}ms
      """
    )
  end
end
