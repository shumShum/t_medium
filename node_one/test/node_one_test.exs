defmodule NodeOneTest do
  use ExUnit.Case
  doctest NodeOne

  test "greets the world" do
    assert NodeOne.hello() == :world
  end
end
