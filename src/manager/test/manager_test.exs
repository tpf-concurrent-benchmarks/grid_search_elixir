defmodule ManagerTest do
  use ExUnit.Case
  doctest Manager

  test "TestNewPartition" do
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

  # this tests are not perfect, they can create false positives
  # because of the flattening of the list but it is highly unlikely
  test "TestPartitionsOne" do
    intervals = [
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5)
    ]

    nIntervals = length(intervals)
    maxChunkSize = 5
    partition = Partition.newPartition(intervals, nIntervals, maxChunkSize)

    expected = [
      [
        Interval.newInterval(0, 5, 5),
        Interval.newInterval(0, 10, 5),
        Interval.newInterval(0, 10, 5)
      ],
      [
        Interval.newInterval(5, 10, 5),
        Interval.newInterval(0, 10, 5),
        Interval.newInterval(0, 10, 5)
      ]
    ]
    expected = List.flatten(expected) |> Enum.sort

    mock_callback = fn element -> element end

    actual = Partition.partitionGenerator(partition.splitIntervals, mock_callback, [])
    actual = List.flatten(actual) |> Enum.sort

    assert actual == expected
  end

  test "TestPartitionsMultiple" do
    intervals = [
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5),
      Interval.newInterval(0, 10, 5)
    ]

    nIntervals = length(intervals)
    maxChunkSize = 4
    partition = Partition.newPartition(intervals, nIntervals, maxChunkSize)

    expected = [
      [
        Interval.newInterval(0, 5, 5),
        Interval.newInterval(0, 5, 5),
        Interval.newInterval(0, 10, 5)
      ],
      [
        Interval.newInterval(5, 10, 5),
        Interval.newInterval(0, 5, 5),
        Interval.newInterval(0, 10, 5)
      ],
      [
        Interval.newInterval(0, 5, 5),
        Interval.newInterval(5, 10, 5),
        Interval.newInterval(0, 10, 5)
      ],
      [
        Interval.newInterval(5, 10, 5),
        Interval.newInterval(5, 10, 5),
        Interval.newInterval(0, 10, 5)
      ]
    ]
    expected = List.flatten(expected) |> Enum.sort

    mock_callback = fn element -> element end

    actual = Partition.partitionGenerator(partition.splitIntervals, mock_callback, [])
    actual = List.flatten(actual) |> Enum.sort

    assert actual == expected
  end
end
