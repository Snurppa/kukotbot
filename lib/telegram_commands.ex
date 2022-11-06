defmodule Telegram.Commands do
  require Logger

  def parse_command(update_object) do
    command_text = get_in(update_object, ["message", "text"])
    if command_text && String.starts_with?(command_text, "/") do
      {_, command} = String.split_at(command_text, 1)
      case String.split(command, " ", parts: 2) do
        [cmd, args] -> {String.downcase(cmd), %{args: args, update: update_object}}
        [single_command] -> {String.downcase(single_command), %{args: "", update: update_object}}
      end
    else
      nil
    end
  end


  def execute_command(cmd) do
    case cmd do
      {"echo", %{:args => args, :update => update}} ->
        Logger.debug fn -> "Executing 'echo' with args #{args}" end
        cid = get_in(update, ["message", "chat", "id"])
        name = get_in(update, ["message", "from", "first_name"])
        Telegram.Methods.sendMessage(cid, name <> " sanoi: " <> args)
      {"saa", %{:args => args, :update => update}} ->
        sanitizeed_args = String.replace(args, ~r/\p{P}|[\p{Z}\t\r\n\v\f]/, "")
        Logger.info fn -> "Executing 'saa' with args #{args}" end
        date_to_msg = fn(date_str) ->
          {:ok, dt, _} = DateTime.from_iso8601(date_str)
          {:ok, helsinki} = DateTime.shift_zone(dt, "Europe/Helsinki")
          # minute is represented as integer, pad < 10 numbers with '0'
          minute_formatted = String.pad_leading(Integer.to_string(helsinki.minute), 2, "0")
           "#{helsinki.hour}:#{minute_formatted}"
        end
        if byte_size(sanitizeed_args) > 0 do
          msg = case FMI.search_weather(args) do
            :ok ->
              Enum.random(["Ei pysty, liian hapokasta", "No habla finlandes", "Mitä tuohon nyt sanoisi?", "Soita Pekka Poudalle"])
            temps ->
              temps
              |> Enum.take(6)
              |> Enum.reduce("Sääennuste paikalle '#{args}':", fn(x,acc) ->
                acc <> "\nklo "  <> date_to_msg.(hd(x)) <> "\t\t" <> Enum.at(x,1) <> "°C"
              end)
          end
          cid = get_in(update, ["message", "chat", "id"])
          Telegram.Methods.sendMessage(cid, msg)
        else
          Logger.warn fn -> "Args were bad, no request sent!" end
          text = Enum.random(["Herää pahvi", "Ei pysty, liian hapokasta", "No habla finlandes", "Mitä tuohon nyt sanoisi?"])
          cid = get_in(update, ["message", "chat", "id"])
          Telegram.Methods.sendMessage(cid, text)
        end
      {"kajaani", %{:update => update}} ->
        cid = get_in(update, ["message", "chat", "id"])
        msgs = ["Kajjaaaani! Ostikko jo junaliput pois?", "Mantan rilliltä makkaraperunat... Ja menossa.", "Millon Vimpeliin?", "Hokki Liigaan!", "Neo nähty Luotikujalla"]
        Telegram.Methods.sendMessage(cid, Enum.random(msgs))
      {"moro", %{:update => update}} ->
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
