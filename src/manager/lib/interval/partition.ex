# lib/interval/partition.ex

defmodule Partition do
  defstruct nPartitions: 0,
            currentPartition: 0,
            nIntervals: 0,
            iterations: 0,
            intervals: nil,
            partitionsPerInterval: nil,
            splitIntervals: nil,
            currentIndex: nil

  def newPartition(intervals, nIntervals, _maxChunkSize) do
    %Partition{nIntervals: nIntervals, intervals: intervals}
  end

  def available(partition) do
    partition.currentPartition < partition.nPartitions
  end

  def calculateAmountOfMissingPartitions(minBatches, fullPartitionSize) do
    :math.ceil(minBatches / fullPartitionSize)
  end

  def calculatePartitionPerInterval(partition, minBatches) do
    fullPartitionSize = 1

    calculate_partitions_per_interval(partition.intervals, minBatches, fullPartitionSize, [])
  end

  defp calculate_partitions_per_interval([], _minBatches, _fullPartitionSize, partitionsPerInterval), do: Enum.reverse(partitionsPerInterval)

  defp calculate_partitions_per_interval([interval | rest], minBatches, fullPartitionSize, partitionsPerInterval) do
    IO.puts("fullPartitionSize: #{fullPartitionSize}")

    missingPartitions = calculateAmountOfMissingPartitions(minBatches, fullPartitionSize)
    elements = interval.size

    {newFullPartitionSize, currPartitionSize} =
      if elements > missingPartitions do
        {fullPartitionSize * missingPartitions, missingPartitions}
      else
        {fullPartitionSize * elements, elements}
      end

    calculate_partitions_per_interval(rest, minBatches, newFullPartitionSize, [currPartitionSize | partitionsPerInterval])
  end

  def split(partition, maxChunkSize) do
    minBatches = :math.floor(fullCalculationSize(partition) / maxChunkSize) + 1
  end

  def fullCalculationSize(partition) do
    partition.intervals |> Enum.reduce(1, fn x, acc -> acc * x.size end)
  end
end
