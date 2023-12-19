defmodule ConfigReader do
  @behaviour Config.Provider

  def init(path) when is_binary(path), do: path

  def load(config, path) do
    {:ok, _} = Application.ensure_all_started(:jason)

    json = path |> File.read!() |> Jason.decode!()

    json
  end
end
