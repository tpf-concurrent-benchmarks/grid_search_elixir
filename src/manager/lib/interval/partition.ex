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

  def calcPartitionAmount(partitionsPerInterval) do
    partitionsPerInterval |> Enum.reduce(1, fn x, acc -> acc * x end)
  end

  def calculateAmountOfMissingPartitions(minBatches, partitionsPerInterval) do
    :math.ceil(minBatches / calcPartitionAmount(partitionsPerInterval))
  end

  def calculatePartitionPerInterval(partition, minBatches) do
    partitionsPerInterval = Enum.map(partition.intervals, fn _interval -> 1 end)

    for interval <- partition.intervals do
      missingPartitions = calculateAmountOfMissingPartitions(minBatches, partitionsPerInterval)
      elements = interval.size

      if elements > missingPartitions do
        missingPartitions
      else
        elements
      end
    end
  end

  def split(partition, maxChunkSize) do
    minBatches = :math.floor(fullCalculationSize(partition) / maxChunkSize) + 1
  end

  def fullCalculationSize(partition) do
    partition.intervals |> Enum.reduce(1, fn x, acc -> acc * x.size end)
  end
end
