defmodule Telegram.Updates do

  def get_updates, do: HTTP.JSON.get!(Telegram.bot_url <> "/getUpdates").body

  def get_updates(update_id) do
    body = Poison.encode!(%{"offset": update_id})
    {:ok, resp} = HTTP.JSON.post(Telegram.bot_url <> "/getUpdates", body, [{"Content-type", "application/json"}])
    resp.body
  end

end
