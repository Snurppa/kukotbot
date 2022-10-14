defmodule Kukotbot do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug fn -> "Starting Kukotbot, test value is: #{Application.get_env(:kukotbot, :env_test)} " end
    children = [
      {Kukotbot.State, name: BotState},
      {Telegram.Updates, [BotState]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one,
                                     max_restarts: 10,
                                     max_seconds: 5])
  end
end
