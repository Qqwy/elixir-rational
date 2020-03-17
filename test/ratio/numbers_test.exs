defmodule Ratio.NumbersTest do
  use ExUnit.Case, async: true
  import Ratio, only: [is_rational: 1]
  use ExUnitProperties
  import TestHelper

  alias Numbers, as: N
  use Numbers, overload_operators: true

  @unary_operations [:abs, :minus, :to_float]
  for operation <- @unary_operations do
    test "Numbers.#{operation}/1 has the same result as running Ratio.#{operation}/1 (except casting)" do
      assert Ratio.unquote(operation)(Ratio.new(1, 3)) == N.unquote(operation)(Ratio.new(1, 3))
    end
  end

  @binary_operations [:add, :sub, :mult, :div]
  for operation <- @binary_operations do
    test "Numbers.#{operation}/2 has the same result as running Ratio.#{operation}/2 (except casting)" do
      assert Ratio.unquote(operation)(Ratio.new(1, 2), Ratio.new(3)) ==
               N.unquote(operation)(Ratio.new(1, 2), Ratio.new(3))
    end
  end

  test "Numbers.pow/2 has the same result as running Ratio.pos/2 (except casting)" do
    assert Ratio.pow(Ratio.new(1, 2), 3) == N.pow(Ratio.new(1, 2), 3)
  end

  property "Addition is closed" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert is_rational(a + b)
    end
  end

  property "Addition is commutative" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert a + b == b + a
    end
  end

  property "Addition is associative" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      assert a + b + c == a + (b + c)
    end
  end

  property "Additive identity" do
    check all a <- rational_generator() do
      assert a + 0 == a
      assert 0 + a == a
    end
  end

  property "Additive inverse" do
    check all a <- rational_generator() do
      inverse = Ratio.new(-a.numerator, a.denominator)
      assert a + inverse == Ratio.new(0)
      assert inverse + a == Ratio.new(0)
    end
  end

  property "Subtraction is closed" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert is_rational(a - b)
    end
  end

  property "Subtractive inverse" do
    check all a <- rational_generator() do
      inverse = Ratio.new(-a.numerator, a.denominator)
      assert 0 - inverse == a
      assert 0 - a == inverse
    end
  end

  property "Multiplication is closed" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert is_rational(a * b)
    end
  end

  property "Multiplication is commutative" do
    check all a <- rational_generator(),
              b <- rational_generator() do
      assert a * b == b * a
    end
  end

  property "Multiplication is associative" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      assert a * b * c == a * (b * c)
    end
  end

  property "Multiplicative identity" do
    check all a <- rational_generator() do
      assert a * 1 == a
      assert 1 * a == a
    end
  end

  property "Multiplication by zero is always zero" do
    check all a <- rational_generator() do
      assert a * 0 == Ratio.new(0)
      assert 0 * a == Ratio.new(0)
    end
  end

  property "Division is closed" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              b != Ratio.new(0) do
      assert is_rational(a / b)
    end
  end

  property "Multiplication distributes over Addition" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      assert a * (b + c) == a * b + a * c
    end
  end

  property "Multiplication distributes over Subtraction" do
    check all a <- rational_generator(),
              b <- rational_generator(),
              c <- rational_generator() do
      assert a * (b - c) == a * b - a * c
    end
  end
end
