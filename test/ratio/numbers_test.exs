defmodule Ratio.NumbersTest do
  use ExUnit.Case, async: true
  use Ratio, override_math: false

  alias Numbers, as: N

  @operations [:add, :sub, :mult, :div]
  for operation <- @operations do
    test "Numbers.#{operation}/2 has the same result as running Ratio.#{operation}/2" do
      assert Ratio.unquote(operation)(Ratio.new(1, 2), 3) == N.unquote(operation)(Ratio.new(1, 2), 3)
    end
  end
end
