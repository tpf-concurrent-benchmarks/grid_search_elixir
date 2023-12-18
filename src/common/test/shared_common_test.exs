defmodule SharedCommonTest do
  use ExUnit.Case
  doctest SharedCommon

  test "greets the world" do
    assert SharedCommon.hello() == :world
  end
end
