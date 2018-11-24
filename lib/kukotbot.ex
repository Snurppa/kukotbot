defmodule Kukotbot do
  use Application

  def start(_type, _args) do
    children = [
      {Kukotbot.State, name: BotState},
      {Telegram.Updates, [BotState]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end
end
