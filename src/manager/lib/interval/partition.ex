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

  def calcPartitionsAmount(partitionsPerInterval) do
    partitionsPerInterval |> Enum.reduce(1, fn x, acc -> acc * x end)
  end

  def calculateAmountOfMissingPartitions(minBatches, fullPartitionSize) do
    :math.ceil(minBatches / fullPartitionSize)
  end

  def calculatePartitionPerInterval(partition, minBatches) do
    fullPartitionSize = 1

    calculatePartitionsPerInterval(partition.intervals, minBatches, fullPartitionSize, [])
  end

  defp calculatePartitionsPerInterval([], _minBatches, _fullPartitionSize, partitionsPerInterval), do: Enum.reverse(partitionsPerInterval)

  defp calculatePartitionsPerInterval([interval | rest], minBatches, fullPartitionSize, partitionsPerInterval) do

    missingPartitions = calculateAmountOfMissingPartitions(minBatches, fullPartitionSize)
    elements = interval.size

    {newFullPartitionSize, currPartitionSize} =
      if elements > missingPartitions do
        {fullPartitionSize * missingPartitions, missingPartitions}
      else
        {fullPartitionSize * elements, elements}
      end

      calculatePartitionsPerInterval(rest, minBatches, newFullPartitionSize, [currPartitionSize | partitionsPerInterval])
  end

  def split(partition, maxChunkSize) do
    minBatches = :math.floor(fullCalculationSize(partition) / maxChunkSize) + 1

    partitionsPerInterval = calculatePartitionPerInterval(partition, minBatches)
    nPartitions = calcPartitionsAmount(partitionsPerInterval)

    splitIntervals = Enum.zip(partition.intervals, partitionsPerInterval)
      |> Enum.map(fn {inteval, partitionSize} -> Interval.split(inteval, partitionSize) end)

    iterations = calcPartitionsAmount(partitionsPerInterval)
    currentIndex = List.duplicate(0, partition.nIntervals)
    partition
      |> Map.put(:partitionsPerInterval, partitionsPerInterval)
      |> Map.put(:nPartitions, nPartitions)
      |> Map.put(:splitIntervals, splitIntervals)
      |> Map.put(:iterations, iterations)
      |> Map.put(:currentIndex, currentIndex)
    end

  def fullCalculationSize(partition) do
    partition.intervals |> Enum.reduce(1, fn x, acc -> acc * x.size end)
  end
end
