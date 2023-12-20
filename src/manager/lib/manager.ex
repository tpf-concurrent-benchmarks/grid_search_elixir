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

    partition = Partition.newPartition(Interval.split(interval, 3), 3, 2)
    IO.puts(Partition.fullCalculationSize(partition))
    IO.inspect(Partition.calculatePartitionPerInterval(partition))
    IO.puts("Hello, world!")

    config = ConfigProvider.get_config("../manager/resources/config.json")
    IO.inspect(config)

    children = [
      {Task.Supervisor, name: BaseProtocol.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: BaseProtocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
