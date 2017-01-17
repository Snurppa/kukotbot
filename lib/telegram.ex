defmodule Telegram do
  @bot_url Application.get_env(:kukotbot_api, :telegram_url) <> "bot" <> Application.get_env(:kukotbot_api, :bot_api_key)

  def bot_url, do: @bot_url

  def parse_command(update_object) do
    command_text = get_in(update_object, ["message", "text"])
    if String.starts_with?(command_text, "/") do
      {_, command} = String.split_at(command_text, 1)
      [command, args] = String.split(command, " ", parts: 2)
      %{command: command, args: args, update: update_object}
    else
      nil
    end
  end
end