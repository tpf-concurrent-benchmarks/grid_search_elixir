defmodule DistributedPipeline do
  def start_worker_proxy(worker_type, source, sink) do
    {:ok, worker_pid} = MeasuredWorker.start_link(worker_type, source, sink)

    # Send worker_pid when asked for it
    receive do
      {:pid_req, ref} ->
        send(ref, {:pid_res, worker_pid})
    end

    Utils.wait_for_process(worker_pid)
    {:ok, worker_pid}
  end

  def start_remote_worker(worker_type, source, sink, num) do
    remote = String.to_atom("worker@#{worker_type.name()}_#{num}")
    IO.puts("Remote: #{inspect(remote)}")

    proxy_pid =
      Node.spawn_link(remote, DistributedPipeline, :start_worker_proxy, [
        worker_type,
        source,
        sink
      ])

    IO.puts("Proxy pid: #{inspect(proxy_pid)}")

    # Request the pid of the worker from the proxy on the Node
    send(proxy_pid, {:pid_req, self()})

    receive do
      {:pid_res, worker_pid} ->
        {:ok, worker_pid}
    end
  end

  def main do
    {:ok, logger} = CustomMetricsLogger.connect("manager")
    start_time = :os.system_time(:millisecond)
    distributed_gs()
    end_time = :os.system_time(:millisecond)
    duration = end_time - start_time
    IO.puts("Completion time: #{duration} ms")
    MetricsLogger.timing(logger, "completion_time", duration)
    MetricsLogger.close(logger)
  end

  # DistributedPipeline.distributed_gs
  def distributed_gs do
    config = ConfigReader.get_config("../resources/data.json", :manager)
    IO.puts("Config read: #{inspect(config)}")
    data = Enum.at(config["data"], 0)
    data2 = Enum.at(config["data"], 1)
    data3 = Enum.at(config["data"], 2)
    interval = Interval.newInterval(Enum.at(data, 0), Enum.at(data, 1), Enum.at(data, 2))
    interval2 = Interval.newInterval(Enum.at(data2, 0), Enum.at(data2, 1), Enum.at(data2, 2))
    interval3 = Interval.newInterval(Enum.at(data3, 0), Enum.at(data3, 1), Enum.at(data3, 2))

    partition = Partition.newPartition([interval, interval2, interval3], 3, 10_800_000)
    {:ok, source} = WorkSource.start_link(partition, "MIN")
    IO.puts("Source pid: #{inspect(source)}")
    {:ok, sink} = WorkSink.start_link()
    IO.puts("Sink pid: #{inspect(sink)}")

    workers_replicas = String.to_integer(System.get_env("WORKER_REPLICAS"))

    workers =
      Enum.map(1..workers_replicas, fn num ->
        {:ok, pid} = start_remote_worker(GridSearchWorker, source, sink, num)
        GenServer.cast(pid, :start)
        pid
      end)

    cleanup(source, workers, [], sink)
  end

  # TODO: take away brockers
  def cleanup(source, workers, brokers, sink) do
    Utils.wait_for_process(sink)

    Enum.each(workers, fn worker ->
      IO.puts("Stopping worker: #{inspect(worker)}")
      GenServer.call(worker, :stop)
    end)

    Enum.each(brokers, fn broker ->
      IO.puts("Stopping broker: #{inspect(broker)}")
      GenServer.call(broker, :stop)
    end)

    IO.puts("Stopping Source")
    GenServer.call(source, :stop)
  end
end
