# lib/interval/interval.ex

defmodule Interval do
    defstruct start: 0.0,
              end: 0.0,
              step: 0.0,
              size: 0,
              precision: 10

    def newInterval(start, end_interval, step) do
        size = :math.ceil(div(end_interval - start, step))
        %Interval{start: start, end: end_interval, step: step, size: size}
    end

    def newInterval(start, end_interval, step, precision) do
        size = :math.ceil(div(end_interval - start, step))
        %Interval{start: start, end: end_interval, step: step, size: size, precision: precision}
    end

    def round_float(value, precision) do
        value |> Decimal.from_float() |> Decimal.round(precision)
    end

    def split_evenly(interval, n_partitions) do
        #TODO test
        for j <- 0..(n_partitions - 1) do
          sub_start = round_float(interval.start + j * interval.size / n_partitions * interval.step, interval.precision)
          sub_end = round_float(interval.start + (j + 1) * interval.size / n_partitions * interval.step, interval.precision)

          intervals = %Interval{
            start: sub_start,
            end: sub_end,
            step: interval.step,
            size: div(:math.ceil(sub_end - sub_start), interval.step),
            precision: interval.precision
          }

          intervals
        end
    end
end
