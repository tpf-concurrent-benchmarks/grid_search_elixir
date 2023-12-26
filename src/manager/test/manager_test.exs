defmodule ManagerTest do
  use ExUnit.Case
  doctest Manager

  test "greets the world" do
    assert Manager.hello() == :world
  end

  test "TestPartitionsOne" do
    intervals = [
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5)
    ]

    nIntervals = len(intervals)
    maxChunkSize = 5
    partition = Partition.newPartition(intervals, nIntervals, maxChunkSize)
  end
end
