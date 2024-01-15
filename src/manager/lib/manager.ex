defmodule Manager do
  @moduledoc false

  use Application

  def main(args \\ []) do
    start(:normal, args)
  end

  @spec start(Application.app(), Application.restart_type()) :: Supervisor.on_start()
  def start(_type, _args) do
    interval = Interval.newInterval(0, 10, 1)
    # IO.inspect(interval)
    # IO.inspect(Interval.split(interval, 2))
    # IO.inspect(Interval.split(interval, 3))
    interval2 = Interval.newInterval(0, 10, 1)
    interval3 = Interval.newInterval(0, 10, 1)

    partition = Partition.newPartition([interval, interval2, interval3], 3, 50)
    # IO.inspect(Partition.calculatePartitionPerInterval(partition, 3))
    # IO.inspect(partition)
    # for i <- 1..round(partition.nPartitions) do
    #   {partition, intervalss} = Partition.next(partition)
    #   # IO.inspect(intervalss)
    #   IO.inspect(partition)
    # end
    IO.inspect(partition)

    Enum.reduce(1..round(partition.nPartitions), partition, fn _, acc ->
      {acc, intervals} = Partition.next(acc)
      IO.inspect(intervals)
      IO.inspect(acc.currentPartition)
      acc
    end)

    IO.puts("end review")

    #config = ConfigReader.get_config("../manager/resources/data.json", :manager)
    #IO.inspect(config)

    # children = [
    #   {Task.Supervisor, name: BaseProtocol.TaskSupervisor}
    # ]

    # opts = [strategy: :one_for_one, name: BaseProtocol.Supervisor]
    # Supervisor.start_link(children, opts)
  end
end
