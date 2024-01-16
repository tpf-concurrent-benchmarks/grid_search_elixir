defmodule GridSearch do
  @moduledoc false
  defstruct params: %{}, accum_type: "", result: 0.0, total_inputs: 0, input: []

  defmodule Accumulator do
    @moduledoc false

    defstruct true_result: 0.0, true_input: %{}, callback: &GridSearch.Accumulator.avg/2

    def new(accum_type) do
      case accum_type do
        "MAX" ->
          %Accumulator{
            true_result: :math.pow(2.0, -1022),
            callback: &GridSearch.Accumulator.max/3
          }

        "MIN" ->
          %Accumulator{
            true_result: :math.pow(2.0, 1023) * (2.0 - :math.pow(2.0, -52)),
            callback: &GridSearch.Accumulator.min/3
          }

        _ ->
          %Accumulator{}
      end
    end

    def accumulate(accumulator, res, current) do
      callback_fun = accumulator.callback
      callback_fun.(res, current, accumulator)
    end

    def max(res, current, %{true_result: true_result} = accumulator) do
      if res > true_result do
        %{accumulator | true_result: res, true_input: current}
      else
        accumulator
      end
    end

    def min(res, current, %{true_result: true_result} = accumulator) do
      if res < true_result do
        %{accumulator | true_result: res, true_input: current}
      else
        accumulator
      end
    end

    def avg(res, %{true_result: true_result} = accumulator) do
      %{accumulator | true_result: true_result + res}
    end
  end

  defmodule Params do
    defstruct start: [], finish: [], step: [], current: [], total_iterations: 0

    def new(start, finish, step) do
      total_iterations =
        Enum.reduce(start, 1, fn s, acc ->
          cum_param =
            Float.floor(
              (Enum.at(finish, trunc(s)) - Enum.at(start, trunc(s))) / Enum.at(step, trunc(s))
            )

          cum_param = if cum_param == 0, do: 1, else: cum_param

          acc * cum_param
        end)

      %Params{
        start: start,
        finish: finish,
        step: step,
        current: start,
        total_iterations: total_iterations
      }
    end

    def get_current(%Params{current: current} = params) do
      current
    end

    def next(%Params{start: start, finish: finish, step: step, current: current} = params) do
      {new_current, _} =
        Enum.zip([current, step, finish, start])
        |> Enum.reduce({[], false}, fn {current_val, step_val, finish_val, start_val},
                                       {acc, incremented} ->
          if incremented do
            {[current_val | acc], incremented}
          else
            if current_val + step_val < finish_val do
              {[current_val + step_val | acc], true}
            else
              {[start_val | acc], incremented}
            end
          end
        end)

      new_current = Enum.reverse(new_current)
      %Params{params | current: new_current}
    end
  end

  def search(grid_search, callback) do
    accumulator = Accumulator.new(grid_search.accum_type)

    {:ok, accum, params} =
      Enum.reduce(
        0..trunc(grid_search.params.total_iterations - 1),
        {:ok, accumulator, grid_search.params},
        fn _, {:ok, acc, params} ->
          current = Params.get_current(params)
          res = callback.(current)
          new_acc = Accumulator.accumulate(acc, res, current)
          new_params = Params.next(params)
          {:ok, new_acc, new_params}
        end
      )

    %GridSearch{
      params: params,
      accum_type: grid_search.accum_type,
      result: accum.true_result,
      total_inputs: params.total_iterations,
      input: accum.true_input
    }
  end
end
