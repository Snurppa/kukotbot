defmodule Telegram do
  require Logger
  @bot_url Application.get_env(:kukotbot, :telegram_url) <> "bot" <> Application.get_env(:kukotbot, :bot_api_key)

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

  def process_update(update) do
    cmd = parse_command(update)
    if cmd do
      Logger.info fn -> "Got command #{cmd.command} with args #{cmd.args}" end
      cmd
    end
  end

  def process_updates(updates) do # process in parallel processes?
    if length(updates) > 0 do
      Logger.info fn ->
        "Received #{length(updates)} updates"
      end
      updates
      |> Enum.map(&process_update/1)
      |> Enum.filter(&is_map/1)
    end
  end

  def get_update do
    Telegram.Updates.get_updates
    |> process_updates
    |> Poison.encode!
  end
end
