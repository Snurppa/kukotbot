defmodule Kukotbot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      #worker(Kukotbot.Web, []),
      worker(Telegram.Updates, [])
    ]

    opts = [strategy: :one_for_one, name: Kukotbot.Supervisor, max_restarts: 5, max_seconds: 10]
    Supervisor.start_link(children, opts)
  end
end
