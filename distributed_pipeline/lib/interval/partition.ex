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

  def newPartition(intervals, nIntervals, maxChunkSize) do
    partition = %Partition{nIntervals: nIntervals, intervals: intervals}
    split(partition, maxChunkSize)
  end

  def available(partition) do
    partition.currentPartition < partition.nPartitions
  end

  def next(%Partition{splitIntervals: splitIntervals, currentIndex: currentIndex, partitionsPerInterval: partitionsPerInterval, currentPartition: currentPartition} = partition) do
    {new_current, currentIntervals, _} =
      Enum.zip([currentIndex, partitionsPerInterval, splitIntervals])
      |> Enum.reduce({[], [], false}, fn {current_val, finish_val, splitInterval},
                                     {acc, intervals, incremented} ->
        interval = Enum.at(splitInterval, current_val)
        if incremented do
          {[current_val | acc], [interval | intervals], incremented}
        else
          if current_val + 1 < finish_val do
            {[current_val + 1 | acc], [interval | intervals], true}
          else
            {[0 | acc], [interval | intervals], incremented}
          end
        end
      end)

    new_current = Enum.reverse(new_current)
    currentIntervals = Enum.reverse(currentIntervals)
    {%Partition{partition | currentIndex: new_current, currentPartition: currentPartition + 1}, currentIntervals} #TODO: remove currentPartition if it is not being used anywhere
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

  defp calculatePartitionsPerInterval([], _minBatches, _fullPartitionSize, partitionsPerInterval),
    do: Enum.reverse(partitionsPerInterval)

  defp calculatePartitionsPerInterval(
         [interval | rest],
         minBatches,
         fullPartitionSize,
         partitionsPerInterval
       ) do
    missingPartitions = calculateAmountOfMissingPartitions(minBatches, fullPartitionSize)
    elements = interval.size

    {newFullPartitionSize, currPartitionSize} =
      if elements > missingPartitions do
        {fullPartitionSize * missingPartitions, missingPartitions}
      else
        {fullPartitionSize * elements, elements}
      end

    calculatePartitionsPerInterval(rest, minBatches, newFullPartitionSize, [
      currPartitionSize | partitionsPerInterval
    ])
  end

  def split(partition, maxChunkSize) do
    minBatches = :math.floor(fullCalculationSize(partition) / maxChunkSize) + 1

    partitionsPerInterval = calculatePartitionPerInterval(partition, minBatches)
    nPartitions = calcPartitionsAmount(partitionsPerInterval)

    splitIntervals =
      Enum.zip(partition.intervals, partitionsPerInterval)
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

  def partitionGenerator([head], senderFun, prev) do
    for elem <- head do
      senderFun.([elem | prev])
    end
  end

  def partitionGenerator([head | tail], senderFun, prev) do
    for elem <- head do
      partitionGenerator(tail, senderFun, [elem | prev])
    end
  end

  # this bounded version may be faster than the recursive one
  def partitionGenerator3elems(x, y, z, senderFun) do
    for elemX <- x, elemY <- y, elemZ <- z, do: senderFun.(elemX, elemY, elemZ)
  end
end
