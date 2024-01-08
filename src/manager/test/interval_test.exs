defmodule IntervalTest do
  use ExUnit.Case
  doctest Interval

  def genericTest(interval, split, expected) do
    assert Interval.split(interval, split) == expected
  end

  test "creates a new interval" do
    interval = Interval.newInterval(1, 5, 2)
    assert interval.start == 1
    assert interval.end == 5
    assert interval.step == 2
    assert interval.size == 2
  end

  test "even split with whole positive numbers" do
    interval = Interval.newInterval(0, 10, 1)
    expected = [
      Interval.newInterval(0, 5, 1),
      Interval.newInterval(5, 10, 1)
    ]
    genericTest(interval, 2, expected)
  end

  test "even split with whole negative numbers" do
    interval = Interval.newInterval(-10, 10, 1)
    expected = [
      Interval.newInterval(-10, 0, 1),
      Interval.newInterval(0, 10, 1)
    ]
    genericTest(interval, 2, expected)
  end
  test "even split with whole negative numbers odd split amount" do
    interval = Interval.newInterval(-600, 600, 1)
    expected = [
      Interval.newInterval(-600, -200, 1),
      Interval.newInterval(-200, 200, 1),
      Interval.newInterval(200, 600, 1)
    ]
    genericTest(interval, 3, expected)
  end

  test "uneven split" do
    interval = Interval.newInterval(0, 10, 3)
    expected = [
      Interval.newInterval(0, 6, 3),
      Interval.newInterval(6, 9, 3),
      Interval.newInterval(9, 12, 3)
    ]
    genericTest(interval, 3, expected)
  end

  test "uneven split with negative numbers" do
    interval = Interval.newInterval(-10, 10, 3)
    expected = [
      Interval.newInterval(-10, -1, 3),
      Interval.newInterval(-1, 8, 3),
      Interval.newInterval(8, 11, 3)
    ]
    genericTest(interval, 3, expected)
  end

  test "even split with float step" do
    interval = Interval.newInterval(0, 30, 0.5)
    expected = [
      Interval.newInterval(0.0, 10.0, 0.5),
      Interval.newInterval(10.0, 20.0, 0.5),
      Interval.newInterval(20.0, 30.0, 0.5)
    ]
    genericTest(interval, 3, expected)
  end

  test "uneven split with float step" do
    interval = Interval.newInterval(0, 10, 0.5)
    expected = [
      Interval.newInterval(0, 3.5, 0.5),
      Interval.newInterval(3.5, 7, 0.5),
      Interval.newInterval(7, 10, 0.5)
    ]
    genericTest(interval, 3, expected)
  end

  test "uneven split with float start and end and step" do
    interval = Interval.newInterval(0.5, 10.5, 0.5)
    expected = [
      Interval.newInterval(0.5, 4.0, 0.5),
      Interval.newInterval(4.0, 7.5, 0.5),
      Interval.newInterval(7.5, 10.5, 0.5)
    ]
    genericTest(interval, 3, expected)
  end
end
