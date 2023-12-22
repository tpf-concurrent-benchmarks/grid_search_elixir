defmodule Manager do
  @moduledoc false

  use Application

  @spec start(Application.app(), Application.restart_type()) :: Supervisor.on_start()
  def start(_type, _args) do
    IO.puts("Hello, world!")
    interval = Interval.newInterval(0, 10, 1)
    IO.inspect(interval)
    IO.inspect(Interval.split(interval, 2))
    IO.inspect(Interval.split(interval, 3))
    interval2 = Interval.newInterval(0, 10, 1)
    interval3 = Interval.newInterval(0, 10, 1)

    partition = Partition.newPartition([interval, interval2, interval3], 1, 2)
    IO.inspect(Partition.calculatePartitionPerInterval(partition, 3))
    IO.inspect(partition)
    IO.puts("end review")


    config = ConfigProvider.get_config("../manager/resources/config.json")
    IO.inspect(config)

    children = [
      {Task.Supervisor, name: BaseProtocol.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: BaseProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
