defmodule Ratio.NumbersTest do
  use ExUnit.Case, async: true
  use Ratio, override_math: false

  alias Numbers, as: N

  @unary_operations [:abs, :minus, :to_float]
  for operation <- @unary_operations do
    test "Numbers.#{operation}/1 has the same result as running Ratio.#{operation}/1" do
      assert Ratio.unquote(operation)(Ratio.new(1, 3)) == N.unquote(operation)(Ratio.new(1, 3))
    end
  end

  @binary_operations [:add, :sub, :mult, :div, :pow]
  for operation <- @binary_operations do
    test "Numbers.#{operation}/2 has the same result as running Ratio.#{operation}/2" do
      assert Ratio.unquote(operation)(Ratio.new(1, 2), 3) == N.unquote(operation)(Ratio.new(1, 2), 3)
    end
  end

end
