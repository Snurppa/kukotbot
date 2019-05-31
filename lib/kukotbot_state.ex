defmodule Kukotbot.State do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> 0 end, opts)
  end

  def get_next_id(pid) do
    id = Agent.get(pid, fn  id -> id end)
    Agent.update(pid, fn id -> id + 1 end)
    id
  end

  def get_id(pid) do
    Agent.get(pid, fn  id -> id end)
  end

  def set_id(pid, new_id) do
    Agent.update(pid, fn _ -> new_id end)
  end

end
