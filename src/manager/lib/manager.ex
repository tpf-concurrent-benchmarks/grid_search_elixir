defmodule Manager do
  @moduledoc """
  Documentation for `Manager`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Manager.hello()
      :world

  """


  def main do
    IO.puts "Hello, world!"
    interval = Interval.newInterval(0, 10, 1)
    IO.inspect(interval)
    IO.puts Interval.round_float(1.23456789, 2)
    IO.inspect(Interval.split_evenly(interval, 2))
    # value1 = Decimal.new("5.0000000000")
    # value2 = Decimal.new("0.0000000001")

    # IO.inspect value1
    # IO.inspect value2

    # result = value1 - value2

    # IO.puts "Result: #{Decimal.to_string(result)}"
  end
end
