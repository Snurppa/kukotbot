defmodule Telegram.Commands do
  require Logger

  def parse_command(update_object) do
    command_text = get_in(update_object, ["message", "text"])
    if command_text && String.starts_with?(command_text, "/") do
      {_, command} = String.split_at(command_text, 1)
      case String.split(String.downcase(command), " ", parts: 2) do
        [cmd, args] -> {String.to_atom(cmd), %{args: args, update: update_object}}
        [single_command] -> {String.to_atom(single_command), %{args: "", update: update_object}}
      end
    else
      nil
    end
  end


  def execute_command(cmd) do
    case cmd do
      {:echo, %{:args => args, :update => update}} ->
        Logger.info fn -> "Executing 'echo' with args #{args}" end
        cid = get_in(update, ["message", "chat", "id"])
        name = get_in(update, ["message", "from", "first_name"])
        Telegram.Methods.sendMessage(cid, name <> " sanoi: " <> args)
      {:saa, %{:args => args, :update => update}} ->
        Logger.info fn -> "Executing 'saa' with args #{args}" end
        date_to_msg = fn(date_str) ->
          {:ok, dt, _} = DateTime.from_iso8601(date_str)
          local_h = dt.hour + 3 # yes, summer time hardcoded
          to_string(local_h) <> ":" <> String.pad_leading(to_string(dt.minute), 2, "0")
        end
        msg = case FMI.search_weather(args) do
          :ok ->
            Enum.random(["Ei pysty, liian hapokasta", "No habla finlandes", "Mitä tuohon nyt sanoisi?"])
          temps ->
            temps
            |> Enum.take(6)
            |> Enum.reduce("Sääennuste paikalle '#{args}':", fn(x,acc) ->
              acc <> "\nklo "  <> date_to_msg.(hd(x)) <> " " <> Enum.at(x,1) <> "°C" end)
        end
        cid = get_in(update, ["message", "chat", "id"])
        Telegram.Methods.sendMessage(cid, msg)
      {:kajaani, %{:args => args, :update => update}} ->
        cid = get_in(update, ["message", "chat", "id"])
        msgs = ["Kajjaaaani! Ostikko jo junaliput pois?", "Mantan rilliltä makkaraperunat... Ja menossa.", "Millon Vimpeliin?", "Hokki Liigaan!"]
        Telegram.Methods.sendMessage(cid, Enum.random(msgs))
      {:moro, %{:update => update}} ->
        cid = get_in(update, ["message", "chat", "id"])
        nimi = get_in(update, ["message", "from", "first_name"])
        Telegram.Methods.sendMessage(cid, "Moro vaan #{nimi}!")
      {fail, %{:update => update}} ->
        cid = get_in(update, ["message", "chat", "id"])
        Logger.warn fn -> "Unknown command #{fail}" end
        Telegram.Methods.sendMessage(cid, "Sori '#{fail}' ei oo tuttu...")
    end
    {_, %{:update => update}} = cmd
    update
  end

end