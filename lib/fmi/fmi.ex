defmodule FMI do
  @moduledoc """
    FMI weather data
  """
  require Logger

  @fmi_get_feature_url Application.get_env(:kukotbot, :fmi_host) <> "/wfs?request=getFeature"
  @ecmwf_point "ecmwf::forecast::surface::point::timevaluepair"

  def query_feature(stored_query, params_str) do
    HTTPoison.get(@fmi_get_feature_url <> "&storedquery_id=" <> stored_query <> "&" <> params_str)
  end

  def get_xml_temps(xml_data) do
    Exml.get(xml_data, "/wfs:FeatureCollection/wfs:member/omso:PointTimeSeriesObservation[.//wml2:MeasurementTimeseries[@gml:id='mts-1-1-Temperature']]//wml2:MeasurementTimeseries//wml2:MeasurementTVP")
  end

  def parse_xml(xmlstr) do
    xmlstr
    |> String.replace("\n","")
    |> Exml.parse([space: :normalize])
  end

  def get_temps(xmlstr) do
    parse_xml(xmlstr)
    |> get_xml_temps
  end

  def sanitized_temps(temps) do
    temps
    |> Enum.map(fn measurement -> Enum.filter(measurement, fn row_item -> byte_size(String.trim(row_item)) > 0 end) end)
  end

  def search_weather(place) when byte_size(place) > 0  do
    Logger.info fn -> "Searching weather for #{place}" end
    case query_feature(@ecmwf_point, "place=" <> place) do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.info fn -> "200 Weather received for #{place}" end
        body
        |> get_temps
        |> sanitized_temps
      {:ok, %{status_code: 400}} ->
        Logger.warn fn -> "400 Weather error for #{place}" end
      {:error, %{reason: reason}} ->
        Logger.error fn -> "Weather search_weather failure: #{reason}" end
    end
  end

  def search_weather("") do
    Logger.info fn -> "Weather: received no args, doing nothing" end
  end
end
