defmodule Telegram.Updates do
  use Task, restart: :permanent
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
    payload = %{offset: update_id, timeout: 300}
    case Telegram.post(@updates_path, payload, [], [recv_timeout: 310000]) do
      {:ok, %{:body => body}} ->
        if body["ok"] do
          Map.get(body, "result")
        else
         Logger.error fn -> "getUpdates API error: #{body["description"]}" end
         []
       end
      {:error, response} ->
        Logger.error fn -> "Telegram getUpdates failure: #{inspect(response)}" end
        []
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
      end
    end
  end

  def get_update do
    get_updates()
    |> process_updates
  end

  def update_loop(bot_state_pid) do
    update_id = Kukotbot.State.get_id(bot_state_pid)
    Logger.debug fn -> "Update loop with id " <> to_string(update_id) end
    updates = get_updates(update_id)
    last_update = Enum.max_by(updates, fn(u) -> Map.get(u, "update_id") end)
    Kukotbot.State.set_id(bot_state_pid, Map.get(last_update, "update_id") + 1)
    process_updates(updates)
    update_loop(bot_state_pid)
  end

  def start_link(args) do
    Logger.info fn -> "Starting Task update_loop" end
    state_agent = hd args
    Task.start_link(__MODULE__, :update_loop, [state_agent])
  end

end
