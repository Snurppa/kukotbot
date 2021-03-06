defmodule Telegram.Methods do
  @moduledoc """
  https://core.telegram.org/bots/api#sendmessage
  Parameters
    char_id
    text
    parse_mode
    disable_web_page_preview
    disable_notification
    reply_to_message_id
    reply_markup
  """
  require Logger

  def getMe do
    Telegram.get!("/getMe")
    |> Map.get(:body)
    |> Map.get("result")
  end

  def sendMessage(cid, text) do
    case Telegram.post("/sendMessage", %{:text => text, :chat_id => cid}) do
      {:ok, %{:status_code => 200, :body => body}} ->
        if body["ok"] do
          chat = get_in(body, ["result", "chat"])
          Logger.info fn ->
            "200 sendMessage successfully sent message to chat: " <> inspect(chat)
          end
          body
        else
         Logger.error fn -> "200 sendMessage not ok: #{body["description"]}" end
        end
      {:ok, %{:status_code => 400, :body => body}} ->
        Logger.error fn -> "400 sendMessage API error: #{body["description"]}" end
      {:error, %{reason: reason}} ->
        Logger.error fn -> "Telegram sendMessage failure: #{reason}" end
    end
  end

end
