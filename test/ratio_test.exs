defmodule RatioTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import TestHelper

  import Ratio, only: [<|>: 2, is_rational: 1]
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

  property "Addition is closed" do
    check all a <- rational_generator(),
      b <- rational_generator() do
      assert is_rational(Ratio.add(a, b))
    end
  end

  property "Addition is commutative" do
    check all a <- rational_generator(),
      b <- rational_generator() do
      assert Ratio.add(a, b) == Ratio.add(b, a)
    end
  end

  property "Addition is associative" do
    check all a <- rational_generator(),
      b <- rational_generator(),
      c <- rational_generator() do
      assert Ratio.add(Ratio.add(a, b), c) == Ratio.add(a, Ratio.add(b, c))
    end
  end


  property "Additive identity" do
    check all a <- rational_generator() do
      assert Ratio.add(a, Ratio.new(0)) == a
      assert Ratio.add(Ratio.new(0), a) == a
    end
  end

  property "Additive inverse" do
    check all a <- rational_generator() do
      inverse = Ratio.new(-a.numerator, a.denominator)
      assert Ratio.add(a, inverse) == Ratio.new(0)
      assert Ratio.add(inverse, a) == Ratio.new(0)
    end
  end

  property "Subtraction is closed" do
    check all a <- rational_generator(),
      b <- rational_generator() do
      assert is_rational(Ratio.sub(a, b))
    end
  end

  property "Subtractive inverse" do
    check all a <- rational_generator() do
      inverse = Ratio.new(-a.numerator, a.denominator)
      assert Ratio.sub(Ratio.new(0), inverse) == a
      assert Ratio.sub(Ratio.new(0), a) == inverse
    end
  end
end
