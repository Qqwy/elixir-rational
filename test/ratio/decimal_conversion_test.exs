defmodule Ratio.DecimalConversionTest do
  use ExUnit.Case, async: true

  @test_cases [
    {Decimal.new("-1230"), Ratio.new(-1230)},
    {Decimal.new("-123"), Ratio.new(-123)},
    {Decimal.new("-12.3"), Ratio.new(-123, 10)},
    {Decimal.new("-1.23"), Ratio.new(-123, 100)},
    {Decimal.new("-0.123"), Ratio.new(-123, 1000)},
    {Decimal.new("-0.0123"), Ratio.new(-123, 10000)},
    {Decimal.new("1230"), Ratio.new(1230)},
    {Decimal.new("123"), Ratio.new(123)},
    {Decimal.new("12.3"), Ratio.new(123, 10)},
    {Decimal.new("1.23"), Ratio.new(123, 100)},
    {Decimal.new("0.123"), Ratio.new(123, 1000)},
    {Decimal.new("0.0123"), Ratio.new(123, 10000)}
  ]

  for {input, output} <- @test_cases do
    test "Proper decimal-> ratio conversion for #{input}" do
      assert Ratio.DecimalConversion.decimal_to_rational(unquote(Macro.escape(input))) ==
               unquote(Macro.escape(output))
    end
  end

  test "Create a ratio with only a Decimal numerator and no denominator (regression test for #111)" do
    assert Ratio.new(Decimal.new(1)) == Ratio.new(1, 1)
  end
end
