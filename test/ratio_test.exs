defmodule RatioTest do
  use ExUnit.Case, async: true
  use Ratio, comparison: true
  doctest Ratio
  doctest Ratio.FloatConversion

  test "definition of <|> operator" do
    assert 1 <|> 3 == %Ratio{numerator: 1, denominator: 3}
  end

  test "reject _ <|> 0" do
    assert_raise ArithmeticError, fn -> 1 <|> 0 end
    assert_raise ArithmeticError, fn -> 1234 <|> 0 end
  end

  test "inspect protocol" do
    assert Inspect.inspect(1 <|> 2, []) == "1 <|> 2"
  end

  test "compare/2" do
    assert Ratio.compare(1, 2) == :lt
    assert Ratio.compare(2, 1) == :gt
    assert Ratio.compare(1 <|> 2, 2 <|> 3) == :lt
    assert Ratio.compare(1 <|> 2, 2 <|> 4) == :eq
  end

  test "lt?/2, lte?/2, gt?/1, gte?/2, equal?/2" do
    assert Ratio.lt?(1 <|> 2, 1)
    refute Ratio.lt?(2, 1 <|> 2)
    refute Ratio.lt?(1 <|> 2, 1 <|> 2)

    refute Ratio.gt?(1 <|> 2, 1)
    assert Ratio.gt?(1 <|> 2, 1 <|> 4)

    assert Ratio.gte?(1 <|> 2, 1 <|> 4)
    assert Ratio.gte?(1 <|> 2, 1 <|> 2)
    refute Ratio.gte?(1 <|> 4, 1 <|> 2)

    assert Ratio.lte?(1 <|> 4, 1 <|> 2)
    assert Ratio.lte?(1 <|> 2, 1 <|> 2)
    refute Ratio.lte?(1 <|> 2, 1 <|> 4)

    assert Ratio.equal?(1 <|> 3, 1 <|> 3)
    refute Ratio.equal?(1 <|> 3, 1 <|> 4)
  end
end
