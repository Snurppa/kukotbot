defmodule Telegram.Updates do
  require Logger

  @updates_path "/getUpdates"

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

  def get_updates do
    Telegram.get!(@updates_path)
    |> Map.get(:body)
    |> Map.get("result")
  end

  @doc """
  Fetches updates from Telegram /getUpdates method.
  Returns collection of Telegram Update maps.
  """
  def get_updates(update_id) do
    payload = %{"offset": update_id}
    case Telegram.post(@updates_path, payload) do
      {:ok, %{:body => body}} ->
        if body["ok"] do
          Map.get(body, "result")
        else
         Logger.error fn -> "getUpdates API error: #{body["description"]}" end
       end
      {:error, response} ->
        Logger.error fn -> "Telegram getUpdates failure: #{response}" end
    end
  end

  def process_update(update) do
    cmd = parse_command(update)
    if cmd do
      Logger.info fn -> "Received command #{cmd.command} with args #{cmd.args}" end
      cmd
    else
      Logger.info fn ->
        "Received plain message '"
        <> get_in(update, ["message", "text"])
        <> "' from user "
        <> get_in(update, ["message", "from", "first_name"])
        <> " " <> get_in(update, ["message", "from", "last_name"])
      end
    end
  end

  def process_updates(updates) do # process in parallel processes?
    if length(updates) > 0 do
      Logger.info fn ->
        "Received #{length(updates)} updates:"
        <> inspect(updates, pretty: true)
      end
      updates
      |> Enum.map(&process_update/1)
      |> Enum.filter(&is_map/1)
    end
  end

  def get_update do
    get_updates
    |> process_updates
  end

end
