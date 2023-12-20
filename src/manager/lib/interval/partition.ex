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

  def calculatePartitionPerInterval(partition) do
    for interval <- partition.intervals do
      1
    end
  end

  def split(partition, maxChunkSize) do
    minBatches = :math.floor(fullCalculationSize(partition) / maxChunkSize) + 1
  end

  def fullCalculationSize(partition) do
    fullCalculationSize(partition.intervals, 1)
  end

  def fullCalculationSize([], fullSize) do
    fullSize
  end

  def fullCalculationSize([head | tail], fullSize) do
    fullCalculationSize(tail, fullSize * head.size)
  end

end
