defmodule HTTP.JSON do
  use HTTPoison.Base

  def process_request_headers(headers) do
    headers ++ ["Accept": "application/json", "Content-Type": "application/json"]
  end

  def process_request_body(body), do: Poison.encode!(body)

  def process_response_body(body) do
    body
    |> Poison.decode!
    # |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end
end