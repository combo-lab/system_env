defmodule CozyEnvTest do
  use ExUnit.Case
  doctest CozyEnv

  test "greets the world" do
    assert CozyEnv.hello() == :world
  end
end
