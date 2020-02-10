# Detour

Detour provides the ability to easily test email deliverability using
simple-to-use assertions against a real SMTP server.

## Installation

Add `detour` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:detour, "~> 0.1", only: :test}]
end
```

## Usage

Ensure `detour` is started before running any tests.

```elixir
ExUnit.start()

Application.ensure_all_started(:detour)
```

To start a `detour` server call `Detour.open/0` or `Detour.open/1` within a
test. Both functions will return a `%Detour{pid: pid, port: pos_integer}`
struct.

`Detour.open/0` will start a `detour` server and assign a random open port.

`Detour.open/1` will start a `detour` server on a port provided as the single
argument. If an attempt is made to start a server on a port that is already in
use then a `:eaddrinuse` error will be returned. Receiving an `:eaddrinuse`
error is common when running tests asynchronously while specifying a static
port.

### Assertions

#### `assert_message_delivered/3`

Ensure a message has successfully been sent.

```elixir
test "a message has been delivered" do
  detour = Detour.open()

  from = "me@notyou.com"

  to = ["you@notme.com"]

  body = "To: you@notme.com\r\nSubject: Hello, world!\r\nFrom: me@notyou.com\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nNice to meet you"

  message = {from, to, body}

  :gen_smtp_client.send_blocking(message, [address: "localhost", port: detour.port])

  assert_message_delivered message
end
```

#### `refute_message_delivered/3`

Ensure a message has not been sent.

```elixir
test "a message has not been delivered" do
  detour = Detour.open()

  from = "me@notyou.com"

  to = ["you@notme.com"]

  body = "To: you@notme.com\r\nSubject: Hello, world!\r\nFrom: me@notyou.com\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nNice to meet you"

  message = {from, to, body}

  :gen_smtp_client.send_blocking({"we@us.com", to, body}, [address: "localhost", port: detour.port])

  refute_message_delivered message
end
```

#### `assert_number_of_messages_delivered/3`

Ensure the expected number of messages has been delivered.

```elixir
test "the expected number of messages have been delivered" do
  detour = Detour.open()

  from = "me@notyou.com"

  to = ["you@notme.com"]

  body = "To: you@notme.com\r\nSubject: Hello, world!\r\nFrom: me@notyou.com\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nNice to meet you"

  message = {from, to, body}

  :gen_smtp_client.send_blocking(message, [address: "localhost", port: detour.port])
  :gen_smtp_client.send_blocking(message, [address: "localhost", port: detour.port])

  assert_number_of_messages_delivered 2
end
```
