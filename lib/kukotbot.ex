defmodule Kukotbot do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Kukotbot.Web, [])
    ]

    opts = [strategy: :one_for_one, name: Kukotbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
