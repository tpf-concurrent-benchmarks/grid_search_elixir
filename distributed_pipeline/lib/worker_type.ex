defmodule WorkerBehaviour do
  @callback do_work(any()) :: any()
  @callback name() :: charlist()
end

defmodule GridSearchWorker do
  @behaviour WorkerBehaviour

  def do_work({starts, ends, steps, accum_type}=params) do
    IO.inspect(params)
    params = GridSearch.Params.new(starts, ends, steps)

    grid_search = %GridSearch{
      params: params,
      accum_type: accum_type,
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
    {:ok, grid_search.result, grid_search.input, grid_search.total_inputs}
  end

  def name do
    "worker"
  end
end
