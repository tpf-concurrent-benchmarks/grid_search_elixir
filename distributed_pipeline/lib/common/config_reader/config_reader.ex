defmodule ConfigReader do
  @behaviour Config.Provider

  def init(path) when is_binary(path), do: path

  defp load(_config, path) do
    {:ok, _} = Application.ensure_all_started(:jason)

    json = path |> File.read!() |> Jason.decode!()

    json
  end

  def get_config(path, app_name) do
    create_config(path, app_name)
    config = Application.get_env(app_name, :config)
    config
  end

  defp create_config(path, app_name) do
    unless File.exists?(path) do
      Logger.error("Config file not found at #{path}")
      System.halt(1)
    end

    config = load([existing: :config, app: [app_name]], path)
    Application.put_env(app_name, :config, config, persistent: true)
  end
end
