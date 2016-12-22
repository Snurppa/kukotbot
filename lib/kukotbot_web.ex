defmodule Kukotbot.Web do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http HexVersion.Web, []
  end

  get "/" do
    conn
    |> send_resp(200, "ok")
    |> halt
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end