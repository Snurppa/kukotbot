defmodule Telegram do
  @bot_url Application.get_env(:kukotbot_api, :telegram_url) <> "bot" <> Application.get_env(:kukotbot_api, :bot_api_key)

  def bot_url, do: @bot_url
end