defmodule WorkerBehaviour do
  @callback do_work(any()) :: any()
  @callback name() :: charlist()
end

defmodule GridSearchWorker do
  @behaviour WorkerBehaviour

  def transform_params(intervals) do
    Enum.reduce(intervals, {[], [], []}, fn interval, {starts, ends, steps} ->
      {starts ++ [interval.start], ends ++ [interval.end], steps ++ [interval.step]}
    end)
  end

  def do_work({intervals, accum_type}) do
    {starts, ends, steps} = transform_params(intervals)
    IO.inspect(transform_params(intervals))
    params = GridSearch.Params.new(starts, ends, steps)

    grid_search = %GridSearch{
      params: params,
      accum_type: accum_type,
      result: 0.0,
      total_inputs: 0,
      input: %{}
    }

    grid_search = GridSearch.search(grid_search, &ObjectiveFun.griewank_fun/1)
    {:ok, grid_search.result, grid_search.input, grid_search.total_inputs}
  end

  def name do
    "worker"
  end
end
