defmodule Kukotbot do
  use Application

  def start(_type, _args) do
    Kukotbot.Supervisor.start_link
  end
end
