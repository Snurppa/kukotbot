defmodule Telegram do
  use HTTPoison.Base

  @bot_url Application.get_env(:kukotbot, :telegram_url) <> "bot" <> Application.get_env(:kukotbot, :bot_api_key)

  def process_url(suffix), do: @bot_url <> suffix
  def process_request_headers(headers) do
    headers ++ ["Accept": "application/json", "Content-Type": "application/json"]
  end

  def process_request_body(body), do: Poison.encode!(body)
  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, result} ->
        result
      {:error, _} ->
        %{ok: false, description: "Telegram response wasn't JSON"}
    end
  end

  def bot_url, do: @bot_url
end
