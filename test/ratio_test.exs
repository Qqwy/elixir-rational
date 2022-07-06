defmodule RatioTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import TestHelper

  import Ratio, only: [<|>: 2, is_rational: 1]
  doctest Ratio
  doctest Ratio.FloatConversion

  test "definition of <|> operator" do
    assert 1 <|> 3 == %Ratio{
             numerator: 1,
             denominator: 3,
             continued_fraction_representation: [1, 0, -3]
           }
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

  test "implicit comparison operators" do
    assert 1 <|> 2 > 1 <|> 3
    assert -1 <|> 2 < 1 <|> 3
    assert 1 <|> 2 > -1 <|> 3
    assert -1 <|> 2 < -1 <|> 3

    assert Ratio.new(-2.3) > Ratio.new(-5.1)
    assert Ratio.new(2.3) > Ratio.new(-5.1)
    assert Ratio.new(-2.3) < Ratio.new(5.1)
    assert Ratio.new(2.3) < Ratio.new(5.1)
  end

  test "small number precision" do
    assert Ratio.equal?(
             Ratio.new(1.602177e-19),
             1_663_795_720_783_351 <|> 10_384_593_717_069_655_257_060_992_658_440_192
           )

    assert Ratio.equal?(
             Ratio.new(1.49241808560e-10),
             5_773_512_823_493_363 <|> 38_685_626_227_668_133_590_597_632
           )
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

  property "Multiplication is closed" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert is_rational(Ratio.mult(a, b))
    end
  end

  property "Multiplication is commutative" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert Ratio.mult(a, b) == Ratio.mult(b, a)
    end
  end

  property "Multiplication is associative" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      assert Ratio.mult(Ratio.mult(a, b), c) == Ratio.mult(a, Ratio.mult(b, c))
    end
  end

  property "Multiplicative identity" do
    check all a <- rational_generator() do
      assert Ratio.mult(a, Ratio.new(1)) == a
      assert Ratio.mult(Ratio.new(1), a) == a
    end
  end

  property "Multiplication by zero is always zero" do
    check all a <- rational_generator() do
      assert Ratio.mult(a, Ratio.new(0)) == Ratio.new(0)
      assert Ratio.mult(Ratio.new(0), a) == Ratio.new(0)
    end
  end

  property "Division is closed" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              b != Ratio.new(0) do
      assert is_rational(Ratio.div(a, b))
    end
  end

  property "Multiplication distributes over Addition" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      left = Ratio.mult(a, Ratio.add(b, c))
      right = Ratio.add(Ratio.mult(a, b), Ratio.mult(a, c))
      assert left == right
    end
  end

  property "Multiplication distributes over Subtraction" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      left = Ratio.mult(a, Ratio.sub(b, c))
      right = Ratio.sub(Ratio.mult(a, b), Ratio.mult(a, c))
      assert left == right
    end
  end

  test "When ceiling a number with denominator 1 it returns nominator" do
    # https://github.com/Qqwy/elixir-rational/issues/89#issuecomment-1139664334
    assert Ratio.new(400) |> Ratio.ceil() == 400
  end
end
