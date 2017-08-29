defmodule Kukotbot.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      #worker(Kukotbot.Web, []),
      worker(Telegram.Updates, [])
    ]

    opts = [strategy: :one_for_one, max_restarts: 5, max_seconds: 10]
    supervise(children, opts)
  end
end
