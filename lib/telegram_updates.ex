defmodule Telegram.Updates do
  @updates_path "/getUpdates"

  def get_updates do
    get_in(HTTP.JSON.get!(Telegram.bot_url <> @updates_path).body, ["result"])
  end

  @doc """
  Fetches updates from Telegram /getUpdates method.
  Returns collection of Telegram Update maps.
  """
  def get_updates(update_id) do
    payload = %{"offset": update_id}
    case HTTP.JSON.post(Telegram.bot_url <> @updates_path, payload) do
      {:ok, %{:body => body}} ->
        if body["ok"] do
          Map.get(body, "result")
        else
         raise "Telegram getUpdates API error: #{body["description"]}"
       end
      {:error, response} ->
        raise "Telegram getUpdates failure: #{response}"
    end
  end

end
