alias Bottle.{CLI, Client}
alias Exampple.Xmpp.Stanza
import Exampple.Xml.Xmlel

CLI.banner "Login user1"

user1 =
  %{
    "domain" => "example.com",
    "host" => "localhost",
    "pass" => "7b9b68a9-dd87-44f9-94b1-869118156c73",
    "resource" => "hectic",
    "user" => "7b9b68a9-dd87-44f9-94b1-869118156c73",
    "process_name" => :user1,

    "to_jid" => "e7264939-6604-4c73-a0ee-26d831ad9ef5@example.com",
    "type" => "chat",
    "payload" => "<body>Hello!</body>",
    "store" => true
  }
  |> Client.connect()
  |> Client.send_template(:auth, ["user", "pass"])
  |> Client.check!(:auth)
  |> Client.send_template(:init, ["host"])
  |> Client.check!(:init)
  |> Client.send_template(:bind, ["resource"])
  |> Client.check!(:bind)
  |> Client.send_template(:presence)
  |> Client.check!(:presence)

CLI.banner "Login user2"

user2 =
  %{
    "domain" => "example.com",
    "host" => "localhost",
    "pass" => "e7264939-6604-4c73-a0ee-26d831ad9ef5",
    "resource" => "hectic",
    "user" => "e7264939-6604-4c73-a0ee-26d831ad9ef5",
    "process_name" => :user2,
    "store" => true
  }
  |> Client.connect()
  |> Client.send_template(:auth, ["user", "pass"])
  |> Client.check!(:auth)
  |> Client.send_template(:init, ["host"])
  |> Client.check!(:init)
  |> Client.send_template(:bind, ["resource"])
  |> Client.check!(:bind)
  |> Client.send_template(:presence)
  |> Client.check!(:presence)

CLI.banner "Send message from user1 to user2"

user1
|> Client.send_template(:message, ["to_jid", "type", "payload"])

CLI.banner "User2 receives the message"

CLI.banner "User2 sends back a reply"

conn =
  user2
  |> Client.recv()
  |> Client.get_conn()

reply = Stanza.message_resp(conn, [~x[<body>OK!</body>]])

user2
|> Client.send_stanza(reply)

user1
|> Client.recv()

CLI.banner "Teardown!"

user1
|> Client.disconnect()

user2
|> Client.disconnect()