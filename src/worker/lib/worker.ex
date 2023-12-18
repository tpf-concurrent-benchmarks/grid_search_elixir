defmodule Worker do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Protocol.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Protocol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
