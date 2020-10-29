defmodule Bottle.Client do
  alias Bottle.CLI
  alias Exampple.Xml.Xmlel

  @default_host "localhost"
  @default_domain "example.com"
  @default_timeout 500
  @default_process_name to_string(Bottle.Client)
  @default_port 5222

  defp await(%{"process_name" => pname} = data, timeout \\ @default_timeout) do
    if (conn = Exampple.Client.get_conn(pname, timeout)) != :timeout do
      if data["store"] do
        Map.put(data, "conns", [conn | data["conns"] || []])
      else
        data
      end
      |> await(timeout)
    else
      data
    end
  end

  defp values(data, keys) do
    keys = Enum.uniq(keys)
    keys = keys -- (keys -- Map.keys(data))
    for key <- keys, do: data[key]
  end

  def send_template(%{"process_name" => pname} = data, name, keys \\ []) do
    Exampple.Client.send_template(name, values(data, keys), pname)
    await(data)
  end

  def send_stanza(data, %Xmlel{} = stanza) do
    send_stanza(data, to_string(stanza))
  end

  def send_stanza(%{"process_name" => pname}, stanza) do
    Exampple.Client.send(stanza, pname)
  end

  def disconnect(data) do
    Exampple.Client.stop(data["process_name"])
    data
  end

  def connect(data \\ %{}, name \\ @default_process_name) do
    data
    |> CLI.add_string("host", @default_host)
    |> CLI.add_string("domain", @default_domain)
    |> CLI.add_atom("process_name", name)
    |> client_start()
    |> register_templates()
    |> client_connect()
    |> await()
  end

  defp client_connect(%{"process_name" => pname} = data) do
    Exampple.Client.connect(pname)
    data
  end

  defp register_templates(%{"process_name" => pname} = data) do
    for {key, fun} <- Bottle.templates(data["domain"]) do
      Exampple.Client.add_template(pname, key, fun)
    end
    data
  end

  defp client_start(%{"process_name" => pname} = data) do
    Exampple.Client.start_link(pname, %{
      host: data["host"],
      domain: data["domain"],
      port: data["port"] || @default_port
    })
    data
  end

  def is_connected?(%{"process_name" => pname}) do
    Exampple.Client.is_connected?(pname)
  end
end