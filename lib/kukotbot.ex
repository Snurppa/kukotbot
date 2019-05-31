defmodule Kukotbot do
  use Application

  def start(_type, _args) do
    children = [
      {Kukotbot.State, name: BotState},
      {Telegram.Updates, [BotState]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one,
                                     max_restarts: 10,
                                     max_seconds: 5])
  end
end
