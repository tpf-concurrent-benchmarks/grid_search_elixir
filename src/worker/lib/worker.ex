defmodule Worker do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: BaseProtocol.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: BaseProtocol.Supervisor]
    Supervisor.start_link(children, opts)

    params = GridSearch.Params.new([0.0, 0.0], [1.0, 1.0], [0.1, 0.1])

    grid_search = %GridSearch{params: params, accum_type: "MAX", result: 0.0, total_inputs: 0, input: %{}}

    callback_function = fn
      parameters -> parameters[0] * parameters[0] + parameters[1] * parameters[1]
      _ -> raise "Invalid arguments for callback function"
    end

    result = GridSearch.search(grid_search, callback_function)

    IO.puts("Final Result: #{result.result}")
    IO.puts("Final Input: #{inspect(result.input)}")

  end
end
