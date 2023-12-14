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
    IO.inspect(Interval.split(interval, 3))
  end
end