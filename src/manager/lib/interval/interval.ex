# lib/interval/interval.ex

defmodule Interval do
    defstruct start: 0.0,
              end: 0.0,
              step: 0.0,
              size: 0,
              precision: 10

    def newInterval(start, end_interval, step) do
        size = round(:math.ceil((end_interval - start) / step))
        %Interval{start: start, end: end_interval, step: step, size: size}
    end

    def newInterval(start, end_interval, step, precision) do
        size = round(:math.ceil((end_interval - start) / step))
        %Interval{start: start, end: end_interval, step: step, size: size, precision: precision}
    end

    def _round(value, precision) do #TODO: add this to an utils module or make private
        rounded_result =
        case value do
          x when is_integer(x) -> x
          x when is_float(x) -> Float.round(x, precision)
          _ -> value
        end
        rounded_result
    end

    def split_evenly(interval, n_partitions) do #TODO: make private when testing is done
        for j <- 0..(n_partitions - 1) do
          sub_start = _round(interval.start + j * interval.size / n_partitions * interval.step, interval.precision)
          sub_end = _round(interval.start + (j + 1) * interval.size / n_partitions * interval.step, interval.precision)

          intervals = newInterval(sub_start, sub_end, interval.step)

          intervals
        end
    end

    def sub_split(interval, maxElemsPerInterval, nSubIntervalsFull) do
        sub_split(interval, maxElemsPerInterval, 0, nSubIntervalsFull, [])
    end

    defp sub_split(interval, maxElemsPerInterval, currentSubIntervalsFull, nSubIntervalsFull, intervals) do
        j = nSubIntervalsFull - 1
        subStart = _round(interval.start + j * maxElemsPerInterval * interval.step, interval.precision)
        subEnd = _round(min(interval.end, subStart + maxElemsPerInterval * interval.step), interval.precision)

        new_intervals = [newInterval(subStart, subEnd, interval.step) | intervals]
        if currentSubIntervalsFull < nSubIntervalsFull - 1 do
            sub_split(interval, maxElemsPerInterval, currentSubIntervalsFull + 1, nSubIntervalsFull, new_intervals)
        else
            {new_intervals, subEnd}
        end
    end

    def split_unevenly(interval, n_partitions) do
        maxElemsPerInterval = round(:math.ceil(interval.size / n_partitions))

        nSubIntervalsFull = round(:math.floor((interval.size - n_partitions) / (maxElemsPerInterval - 1)))

        {intervals, subEnd} = sub_split(interval, maxElemsPerInterval, nSubIntervalsFull)

        intervalReminder = newInterval(subEnd, interval.end, interval.step)
        subIntervalsReminder = split(intervalReminder, n_partitions - nSubIntervalsFull)
        intervals ++ subIntervalsReminder
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
