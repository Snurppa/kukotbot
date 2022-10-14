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
    {:ok, _} = Plug.Adapters.Cowboy.http Kukotbot.Web, []
  end

  get "/" do
    conn
    |> send_resp(200, Telegram.Updates.get_updates(0) |> Poison.encode!)
    |> halt
  end

  get "/ping" do
    conn
    |> send_resp(200, "pong")
    |> halt
  end

  get "/url" do
    conn
    |> send_resp(200, Telegram.bot_url)
    |> halt
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
