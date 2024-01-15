defmodule WorkSource do
  use GenServer

  def start_link(_input_directory, _batch_size) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_params) do
    interval = Interval.newInterval(0, 10, 1)
    interval2 = Interval.newInterval(0, 10, 1)
    interval3 = Interval.newInterval(0, 10, 1)

    partition = Partition.newPartition([interval, interval2, interval3], 3, 50)
    {:ok, {partition, "MAX"}}
  end

  @impl true
  def handle_cast({:ready, pid}, {partition, accum_type}) do
    if not Partition.available(partition) do
      GenServer.cast(pid, :no_work)
      {:noreply, {partition, accum_type}} #TODO: check why this function is called again after finishing
    else
      {partition, intervals} = Partition.next(partition)
      GenServer.cast(pid, {:work, {intervals, accum_type}})
      {:noreply, {partition, accum_type}}
    end
  end

  @impl true
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
end
