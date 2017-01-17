defmodule Telegram.Updates do
  @updates_path "/getUpdates"

  def get_updates do
    HTTP.JSON.get!(Telegram.bot_url <> @updates_path).body
  end

  def get_updates(update_id) do
    payload = %{"offset": update_id}
    case HTTP.JSON.post(Telegram.bot_url <> @updates_path, payload) do
      {:ok, response} ->
        response.body
      {:error, response} ->
        raise "Telegram getUpdates failure: #{response}"
    end
  end

end
