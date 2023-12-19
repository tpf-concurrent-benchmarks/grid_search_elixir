defmodule Manager do
  @moduledoc false

  use Application

  @spec start(Application.app(), Application.restart_type()) :: Supervisor.on_start()
  def start(_type, _args) do
    IO.puts("Hello, world!")
    interval = Interval.newInterval(0, 10, 1)
    IO.inspect(interval)
    # IO.puts(Interval.round_float(1.23456789, 2))
    IO.inspect(Interval.split(interval, 2))
    IO.inspect(Interval.split(interval, 3))

    config = ConfigProvider.get_config("../manager/resources/config.json")
    IO.inspect(config)

    children = [
      {Task.Supervisor, name: Protocol.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Protocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
