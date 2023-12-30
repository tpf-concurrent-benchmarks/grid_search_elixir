defmodule Worker do
  @moduledoc false

  use Application

  @spec start(Application.app(), Application.restart_type()) :: Supervisor.on_start()
  def start(_type, _args) do
    config = ConfigReader.get_config("../worker/resources/config.json", :worker)
    IO.inspect(config)

    children = [
      {Task.Supervisor, name: BaseProtocol.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: BaseProtocol.Supervisor]
    Supervisor.start_link(children, opts)

    params = GridSearch.Params.new([0.0, 0.0], [1.0, 1.0], [0.1, 0.1])

    grid_search = %GridSearch{
      params: params,
      accum_type: "MAX",
      result: 0.0,
      total_inputs: 0,
      input: %{}
    }

    callback_function = fn
      parameters ->
        Enum.at(parameters, 0) * Enum.at(parameters, 0) +
          Enum.at(parameters, 1) * Enum.at(parameters, 1)

      _ ->
        raise "Invalid arguments for callback function"
    end

    grid_search = GridSearch.search(grid_search, callback_function)

    IO.puts("Final Result: #{grid_search.result}")
    IO.puts("Final Input parameters: #{inspect(grid_search.input)}")
    IO.puts("Total iterations: #{inspect(grid_search.total_inputs)}")
  end
end
