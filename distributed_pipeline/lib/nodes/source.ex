defmodule WorkSource do
  use GenServer

  def start_link(partition, accum_type) do
    GenServer.start_link(__MODULE__, {partition, accum_type}, name: __MODULE__)
  end

  @impl true
  def init(params) do
    {:ok, params}
  end

  @impl true
  def handle_cast({:ready, pid}, {partition, accum_type}) do
    if not Partition.available(partition) do
      GenServer.cast(pid, :no_work)
      {:noreply, {partition, accum_type}}
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
