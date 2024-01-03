defmodule ManagerTest do
  use ExUnit.Case
  doctest Manager

  test "TestPartitionsOne" do
    intervals = [
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5)
    ]

    nIntervals = length(intervals)
    maxChunkSize = 5
    partition = Partition.newPartition(intervals, nIntervals, maxChunkSize)

    assert partition.nIntervals == nIntervals
    assert length(partition.intervals) == nIntervals
  end

  test "TestPartitionsPerInterval" do
    intervals = [
      Interval.newInterval(4, 8, 1),
      Interval.newInterval(4, 8, 1),
      Interval.newInterval(8, 10, 1 )
    ]

    nIntervals = length(intervals)
    maxChunkSize = 5
    partition = Partition.newPartition(intervals, nIntervals, maxChunkSize)

    partitionPerInterval = Partition.calculatePartitionPerInterval(partition, 3)

    assert length(partitionPerInterval) == nIntervals

    expected = [3, 1, 1]
    assert partitionPerInterval == expected
  end
end
