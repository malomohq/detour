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


### Starting a Detour Server

`Detour.open/1` can be used to start a Detour server. A Detour server is an
in-memory SMTP server that can be used to receive SMTP traffic and perform
assertions to verify behavior.

`Detour.open/1` returns a `%Detour{}` struct with fields `pid` and `port`. `pid`
is the address of the Detour server and `port` is the port number used when
sending traffic to Detour. The relay used by your SMTP client should always be
`localhost` when sending traffic to a Detour server.

By default, `Detour.open/1` will choose an open port. This is preferable over
specifying a static port as it makes working with Detour more flexible. You can
specify a port by passing the `:port` option to `Detour.open/1`.

When allowing Detour to provide a port Detour will take take care of releasing
the port after a test finishes. If you specify a port you will need to perform
this clean up yourself. You can do this by calling `Detour.shutdown/2` after a
test has run.

#### Examples

When allowing Detour to provide a port.

```elixir
test "automatic port assignment" do
  detour = Detour.open()

  from = "me@notyou.com"

  to = ["you@notme.com"]

  body = "To: you@notme.com\r\nSubject: Hello, world!\r\nFrom: me@notyou.com\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nNice to meet you"

  message = {from, to, body}

  :gen_smtp_client.send_blocking(message, [address: "localhost", port: detour.port])

  assert_message_delivered message
end
```

When providing a port to Detour.

```elixir
test "specifying a port" do
  detour = Detour.open([port: 2525])

  from = "me@notyou.com"

  to = ["you@notme.com"]

  body = "To: you@notme.com\r\nSubject: Hello, world!\r\nFrom: me@notyou.com\r\nContent-Type: text/plain\r\nContent-Transfer-Encoding: quoted-printable\r\n\r\nNice to meet you"

  message = {from, to, body}

  :gen_smtp_client.send_blocking(message, [address: "localhost", port: detour.port])

  assert_message_delivered message

  Detour.shutdown(detour)
end
```

### Message Format

Messages are expected to be in the format `{from, [to], body}`. `from`, `to` and
`body` are all string values. `body` will be the raw text your SMTP client sends
to Detour. This will typically be an RFC2822 encoded string. If your email
library doesn't provide facilities to parse a message body you can use the
[`mail`](https://hex.pm/packages/mail) package.

#### Example

```elixir
def test "rfc2822 messages" do
  detour = Detour.open()

  from = "me@notyou.com"

  to = ["you@notme.com"]

  message =
    Mail.build()
    |> Mail.put_from(from)
    |> Mail.put_to(to)
    |> Mail.put_subject("Hello, world!")
    |> Mail.put_text("Nice to meet you")

  body = Mail.render(message)

  message = {from, to, body}

  :gen_smtp_client.send_blocking(message, [address: "localhost", port: detour.port])

  assert_message_delivered message
end
```

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
