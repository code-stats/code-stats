defmodule CodeStats.RequestTime do
  @moduledoc """
  Plug that adds request time to the conn. It can be used to render the total time taken to
  serve the request.
  """

  import Plug.Conn

  @data_key :codestats_request_start_time

  @time_units [
    "µs", "ms", "s"
  ]

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> put_private(@data_key, get_current_time)
  end

  def calculate_time(conn) do
    old_time = conn.private[@data_key]

    ((get_current_time() - old_time) * 1_000_000)
    |> Float.round()
    |> trunc()
    |> get_unit(@time_units)
    |> format_output()
  end

  defp get_current_time() do
    {millions, seconds, microseconds} = :os.timestamp
    (millions * 1_000_000) + seconds + (microseconds / 1_000_000)
  end

  defp get_unit(value, [unit]), do: {value, unit}

  defp get_unit(value, [_ | units]) when value > 1_000, do: get_unit(value / 1_000, units)

  defp get_unit(value, [unit | _]), do: {value, unit}

  defp format_output({value, unit}) when is_float(value) do
    "#{Float.to_string(value, decimals: 2)} #{unit}"
  end

  defp format_output({value, unit}) when is_integer(value) do
    "#{Integer.to_string(value)} #{unit}"
  end
end
