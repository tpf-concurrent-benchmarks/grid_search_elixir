defmodule WorkerBehaviour do
  @callback do_work(any()) :: any()
  @callback name() :: charlist()
end

defmodule GridSearchWorker do
  @behaviour WorkerBehaviour

  def do_work({interval1, interval2, interval3, accum_type}=params) do
    IO.inspect(params)
    # params = GridSearch.Params.new(interval1, interval2, interval3)

    # grid_search = %GridSearch{
    #   params: params,
    #   accum_type: accum_type,
    #   result: 0.0,
    #   total_inputs: 0,
    #   input: %{}
    # }

    # callback_function = fn
    #   parameters ->
    #     Enum.at(parameters, 0) * Enum.at(parameters, 0) +
    #       Enum.at(parameters, 1) * Enum.at(parameters, 1)

    #   _ ->
    #     raise "Invalid arguments for callback function"
    # end

    # grid_search = GridSearch.search(grid_search, callback_function)
    # grid_search
    0
  end

  def name do
    "worker"
  end
end
