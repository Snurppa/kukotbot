defmodule Telegram.Updates do
  use Task, restart: :permanent
  require Logger

  @updates_path "/getUpdates"

  @doc """
  Fetches updates from Telegram /getUpdates method.
  Returns collection of Telegram Update maps.
  """
  def get_updates(update_id) do
    payload = %{offset: update_id, timeout: Application.get_env(:kukotbot, :longpoll_timeout)}
    case Telegram.post(@updates_path, payload, [], [recv_timeout: 600000]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        if body["ok"] do
          Map.get(body, "result")
        else
         Logger.error fn -> "getUpdates 200 OK API error: #{body["description"]}" end
         []
       end
      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        Logger.error fn -> "Telegram getUpdates not 200 OK, status code was #{status}, body was #{inspect(body)}" end
        []
      {:error, %HTTPoison.Error{reason: :timeout}} ->
        [] # When no upates, request is timed out, expected
      {:error, %HTTPoison.Error{reason: :connect_timeout}} ->
        Logger.error fn -> "Telegram getUpdates timed out: no response from Bot API, waiting 1 min." end
        Process.sleep(60 * 1000)
        []
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

  def process_updates(updates) do # process in parallel processes?
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

  def update_loop(bot_state_pid) do
    update_id = Kukotbot.State.get_id(bot_state_pid)
    Logger.debug fn -> "Update loop with id " <> to_string(update_id) end
    updates = get_updates(update_id)
    new_id = if Enum.empty?(updates) do
               update_id
             else
               updates
               |> Enum.max_by(fn(u) -> Map.get(u, "update_id") end)
               |> Map.get("update_id")
               |> Kernel.+(1)
             end
    Kukotbot.State.set_id(bot_state_pid, new_id)
    process_updates(updates)
    update_loop(bot_state_pid)
  end

  def start_link(args) do
    Logger.info fn -> "Starting Task update_loop" end
    state_agent = hd args
    Task.start_link(__MODULE__, :update_loop, [state_agent])
  end

end
