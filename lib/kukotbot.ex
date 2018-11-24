defmodule Kukotbot do
  use Application

  def start(_type, _args) do
    children = [
      {Telegram.Updates, [0]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end
end
