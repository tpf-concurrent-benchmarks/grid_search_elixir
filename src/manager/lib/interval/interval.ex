# lib/interval/interval.ex

defmodule Interval do
    defstruct start: 0.0,
              end: 0.0,
              step: 0.0,
              size: 0,
              precision: 10

    # def min(a, b) do #TODO: add this to an utils module
    #     if a <= b do
    #         a
    #     else
    #         b
    #     end
    # end

    def newInterval(start, end_interval, step) do
        size = round(:math.ceil((end_interval - start) / step))
        %Interval{start: start, end: end_interval, step: step, size: size}
    end

    def newInterval(start, end_interval, step, precision) do
        size = round(:math.ceil((end_interval - start) / step))
        %Interval{start: start, end: end_interval, step: step, size: size, precision: precision}
    end

    def round_float(value, precision) do #TODO: add this to an utils module or make private
        value |> Decimal.from_float() |> Decimal.round(precision) |> Decimal.to_float()
    end

    def split_evenly(interval, n_partitions) do #TODO: make private when testing is done
        for j <- 0..(n_partitions - 1) do
          sub_start = round_float(interval.start + j * interval.size / n_partitions * interval.step, interval.precision)
          sub_end = round_float(interval.start + (j + 1) * interval.size / n_partitions * interval.step, interval.precision)

          intervals = newInterval(sub_start, sub_end, interval.step)

          intervals
        end
    end

    def sub_split(interval, maxElemsPerInterval, nSubIntervalsFull) do
        sub_split(interval, maxElemsPerInterval, nSubIntervalsFull, [], nil)
    end

    defp sub_split(_, _, 0, intervals, lastSubEnd) do
        {Enum.reverse(intervals), lastSubEnd}
    end

    # def sub_split(interval, maxElemsPerInterval, nSubIntervalsFull) do
    #     for j <- 0..(nSubIntervalsFull - 1) do
    #         subStart = round_float(interval.start + j * maxElemsPerInterval * interval.step, interval.precision)
    #         subEnd = round_float(min(interval.end,subStart + maxElemsPerInterval * interval.step), interval.precision)
    #         intervals = newInterval(subStart, subEnd, interval.step)
    #         intervals
    #     end
    # end

    defp sub_split(interval, maxElemsPerInterval, nSubIntervalsFull, intervals, _) do
        j = nSubIntervalsFull - 1
        subStart = round_float(interval.start + j * maxElemsPerInterval * interval.step, interval.precision)
        subEnd = round_float(min(interval.end, subStart + maxElemsPerInterval * interval.step), interval.precision)

        new_intervals = [newInterval(subStart, subEnd, interval.step) | intervals]

        sub_split(interval, maxElemsPerInterval, nSubIntervalsFull - 1, new_intervals, subEnd)
    end

    def split_unevenly(interval, n_partitions) do
        maxElemsPerInterval = round(:math.ceil(interval.size / n_partitions))

        nSubIntervalsFull = round(:math.floor((interval.size - n_partitions) / (maxElemsPerInterval - 1)))

        intervals = sub_split(interval, maxElemsPerInterval, nSubIntervalsFull)

        # intervalReminder = newInterval()
    end

    def split(interval, n_partitions) do
      cond do
      n_partitions <= 0 ->
        nil
      rem(interval.size, n_partitions) == 0 ->
        split_evenly(interval, n_partitions)
      true ->
        split_unevenly(interval, n_partitions)
      end
    end
end
