defmodule FMI do
  @moduledoc """
    FMI weather data
  """
  require Logger

  @fmi_get_feature_url "http://data.fmi.fi/fmi-apikey/" <> Application.get_env(:kukotbot, :fmi_api_key) <> "/wfs?request=getFeature"
  @fmi_hirlam_point_timevalue "fmi::forecast::hirlam::surface::point::timevaluepair"

  def surface_point_url_for_place(place) do
    @fmi_get_feature_url <> "&storedquery_id=" <> @fmi_hirlam_point_timevalue <> "&place=" <> place
  end

  def parse_temps(xmlstr) do
    xmlstr
    |> String.replace("\n","")
    |> Exml.parse([space: :normalize])
    |> Exml.get("/wfs:FeatureCollection/wfs:member/omso:PointTimeSeriesObservation[.//wml2:MeasurementTimeseries[@gml:id='mts-1-1-Temperature']]//wml2:MeasurementTimeseries//wml2:MeasurementTVP")
  end

  def search_weather(place) when byte_size(place) > 0  do
    Logger.info fn -> "Searching weather for #{place}" end
    url = surface_point_url_for_place(place)
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.info fn -> "200 Weather received for #{place}" end
        temps = parse_temps(body)
        sanitized_temps = temps
        |> Enum.map(fn measurement -> Enum.filter(measurement, fn row_item -> byte_size(String.trim(row_item)) > 0 end) end)
        sanitized_temps
      {:ok, %{status_code: 400}} ->
        Logger.warn fn -> "400 Weather error for #{place}" end
      {:error, response} ->
        Logger.error fn -> "Weather search_weather failure: #{response}" end
    end
  end

  def search_weather("") do
    Logger.info fn -> "Weather: received no args, doing nothing" end
  end
end
