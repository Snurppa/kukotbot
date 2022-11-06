defmodule Kukotbot.Web do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match

  plug Plug.Parsers,
       parsers: [:json],
       pass:  ["application/json"],
       json_decoder: Poison

  plug :dispatch

  get "/" do
    conn
    |> send_resp(200, Telegram.Updates.get_updates(0) |> Poison.encode!)
  end

  get "/ping" do
    conn
    |> send_resp(200, "pong")
  end

  get "/url" do
    conn
    |> send_resp(200, Telegram.bot_url)
  end

  post "/telegram/hook" do
    Logger.info fn -> "Received Telegram POST #{to_string(conn.body_params)}" end
    #IO.inspect conn.body_params # Prints JSON POST body
    send_resp(conn, 200, "Success!")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
