defmodule GridSearch do
  defstruct params: %{}, accum_type: "", result: 0.0, total_inputs: 0, input: %{}

  defmodule Accumulator do
    @moduledoc false

    defstruct true_result: 0.0, true_input: %{}, callback: :avg

    def new(accum_type) do
      case accum_type do
        "MAX" ->
          %Accumulator{true_result: :math.pow(2.0, -1022), callback: &max/2}

        "MIN" ->
          %Accumulator{
            true_result: :math.pow(2.0, 1023) * (2.0 - :math.pow(2.0, -52)),
            callback: &min/2
          }

        _ ->
          %Accumulator{}
      end
    end

    def accumulate(accumulator, res, current) do
      callback_fun = accumulator.callback
      %{accumulator | callback: callback_fun.(res, current)}
    end

    def get_result(%{true_result: result} = accumulator) do
      result
    end

    def get_input(%{true_input: input} = accumulator) do
      input
    end

    defp max(res, current, %{true_result: true_result} = accumulator) do
      if res > true_result do
        %{accumulator | true_result: res, true_input: current}
      else
        accumulator
      end
    end

    defp min(res, current, %{true_result: true_result} = accumulator) do
      if res < true_result do
        %{accumulator | true_result: res, true_input: current}
      else
        accumulator
      end
    end

    defp avg(res, %{true_result: true_result} = accumulator) do
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

          IO.puts("cum param: #{cum_param}")

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
      new_current =
        Enum.reduce_while(step, {current, params}, fn step_val, {current_acc, params_acc} ->
          if current_acc + step_val < Enum.at(finish, 0) do
            {:cont, {current_acc + step_val, params_acc}}
          else
            {:halt, %{params_acc | current: start}}
          end
        end)

      %{params | current: new_current}
    end

    def get_total_iterations(%Params{total_iterations: total_iterations} = params) do
      total_iterations
    end
  end

  def search(grid_search, callback) do
    accumulator = Accumulator.new(grid_search.accum_type)

    {accum, _} =
      Enum.reduce(
        0..(trunc(Params.get_total_iterations(grid_search.params)) - 1),
        {:ok, accumulator},
        fn _, {:ok, acc} ->
          current = Params.get_current(grid_search.params)
          IO.puts(inspect(current))
          IO.puts(inspect(grid_search.params))
          res = callback.(current)
          new_acc = Accumulator.accumulate(acc, res, current)
          new_params = Params.next(grid_search.params)
          {new_acc, new_params}
        end
      )

    true_result = Accumulator.get_result(accum)
    true_input = Accumulator.get_input(accum)

    IO.puts("result: #{true_result}")
    IO.puts("input: #{inspect(true_input)}")
  end

  def fetch(data, key) do
    Map.get(data, key)
  end

  def fetch(%GridSearch{params: params} = data, key) do
    Params.fetch(params, key)
  end

  def fetch(%GridSearch.Params{} = params, key) do
    Params.fetch(params, key)
  end
end
