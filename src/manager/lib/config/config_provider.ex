defmodule ConfigProvider do
  @moduledoc false

  def get_config(path) do
    create_config(path)
    config = Application.get_env(:manager, :config)
    config
  end

  defp create_config(path) do
    # If the path does not exist, log error and exit process
    unless File.exists?(path) do
      Logger.error("Config file not found at #{path}")
      System.halt(1)
    end

    config = ConfigReader.load([existing: :config, app: [:manager]], path)
    Application.put_env(:manager, :config, config, persistent: true)
  end
end
