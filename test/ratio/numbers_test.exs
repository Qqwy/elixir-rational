defmodule Ratio.NumbersTest do
  use ExUnit.Case, async: true
  # import Ratio, only: [<|>: 2]

  alias Numbers, as: N

  @unary_operations [:abs, :minus, :to_float]
  for operation <- @unary_operations do
    test "Numbers.#{operation}/1 has the same result as running Ratio.#{operation}/1 (except casting)" do
      assert Ratio.unquote(operation)(Ratio.new(1, 3)) == N.unquote(operation)(Ratio.new(1, 3))
    end
  end

  @binary_operations [:add, :sub, :mult, :div]
  for operation <- @binary_operations do
    test "Numbers.#{operation}/2 has the same result as running Ratio.#{operation}/2 (except casting)" do
      assert Ratio.unquote(operation)(Ratio.new(1, 2), Ratio.new(3)) == N.unquote(operation)(Ratio.new(1, 2), Ratio.new(3))
    end
  end

  test "Numbers.pow/2 has the same result as running Ratio.pos/2 (except casting)" do
    assert Ratio.pow(Ratio.new(1, 2), 3) == N.pow(Ratio.new(1, 2), 3)
  end
end
