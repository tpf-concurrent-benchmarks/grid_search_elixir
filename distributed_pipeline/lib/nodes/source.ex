defmodule WorkSource do

  use GenServer

  def start_link(_input_directory, _batch_size) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_params) do
    interval_list = [{
      [0, 10, 1],
      [0, 10, 1],
      [0, 10, 1],
      "MAX"
    },
    {
      [0, 10, 1],
      [0, 10, 1],
      [0, 10, 1],
      "MAX"
    },
    {
      [0, 10, 1],
      [0, 10, 1],
      [0, 10, 1],
      "MAX"
    }]
    {:ok, interval_list}
  end

  @impl true
  def handle_cast({:ready, pid}, interval_list) do
    #TODO: pass here the interval cartesian product iterator
    # GenServer.cast(pid, :no_work)
    # GenServer.cast(pid, {:work, serving_files})
    if length(interval_list) == 0 do
      GenServer.cast(pid, :no_work)
      {:noreply, []}
    else
      [head | tail] = interval_list
      GenServer.cast(pid, {:work, head})
      {:noreply, tail}
    end
  end

  @impl true
  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

end
