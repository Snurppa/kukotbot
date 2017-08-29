defmodule Telegram.Updates do
  use Agent
  require Logger

  @updates_path "/getUpdates"

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
    payload = %{"offset": update_id, "timeout": 300}
    case Telegram.post(@updates_path, payload, [], [recv_timeout: 310000]) do
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
    cmd = Telegram.Commands.parse_command(update)
    if is_tuple(cmd) do
      {c, rest} = cmd
      Logger.info fn -> "Received command '#{to_string(c)}' with args #{rest.args}" end
      cmd
    else
      if get_in(update, ["message", "text"]) do
        Logger.info fn ->
          "Received plain message '"
            <> get_in(update, ["message", "text"])
            <> "' from user "
            <> Enum.join([
                get_in(update, ["message", "from", "first_name"]),
                " ",
                get_in(update, ["message", "from", "last_name"])])
        end
      end
    end
  end

  def process_updates(updates \\ 0) do # process in parallel processes?
    if length(updates) > 0 do
      Logger.info fn ->
        "Received #{length(updates)} updates:"
        <> inspect(updates, pretty: true)
      end
      commands = updates
        |> Enum.map(&process_update/1)
        |> Enum.filter(&is_tuple/1)
      if length(commands) > 0 do
        commands
        |> Enum.map(&Telegram.Commands.execute_command/1)
        |> Enum.max_by(fn(u) -> Map.get(u, "update_id") end)
      else
        Enum.max_by(updates, fn(u) -> Map.get(u, "update_id") end)
      end
    end
  end

  def get_update do
    get_updates()
    |> process_updates
  end

  def update_loop(update_id) do
    Logger.info fn -> "Update loop with id " <> to_string(update_id) end
    last_update = get_updates(update_id)
    |> process_updates
    if is_map(last_update) do
      update_loop(Map.get(last_update, "update_id") + 1)
    else
      Process.sleep(10000)
      update_loop(update_id)
    end
  end

  def start_link() do
    Agent.start_link(fn -> update_loop(0) end)
  end

end
