defmodule Telegram do
  use HTTPoison.Base
  require Logger

  def bot_url, do: Application.get_env(:kukotbot, :telegram_url) <> "bot" <> Application.fetch_env!(:kukotbot, :bot_api_key)

  def process_url(suffix) do
    Logger.debug fn -> "URL: #{Application.get_env(:kukotbot, :telegram_url) <> "bot"}" end
    bot_url() <> suffix
  end
  def process_request_headers(headers) do
    headers ++ ["Accept": "application/json", "Content-Type": "application/json"]
  end

  def process_request_body(body), do: Poison.encode!(body)
  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, result} ->
        result
      {:error, _} ->
        %{"ok" => false, "description" => "Telegram response wasn't JSON"}
    end
  end
end
