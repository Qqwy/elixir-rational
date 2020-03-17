defmodule Ratio.DecimalConversionTest do
  use ExUnit.Case, async: true

  use Ratio

  @test_cases [
    {Decimal.new("-1230"), -1230},
    {Decimal.new("-123"), -123},
    {Decimal.new("-12.3"), -123 <|> 10},
    {Decimal.new("-1.23"), -123 <|> 100},
    {Decimal.new("-0.123"), -123 <|> 1000},
    {Decimal.new("-0.0123"), -123 <|> 10000},
    {Decimal.new("1230"), 1230},
    {Decimal.new("123"), 123},
    {Decimal.new("12.3"), 123 <|> 10},
    {Decimal.new("1.23"), 123 <|> 100},
    {Decimal.new("0.123"), 123 <|> 1000},
    {Decimal.new("0.0123"), 123 <|> 10000}
]

    for {input, output} <- @test_cases do
      test "Proper decimal-> ratio conversion for #{input}" do
        assert Ratio.DecimalConversion.decimal_to_rational(unquote(Macro.escape(input))) == unquote(Macro.escape(output))
      end
    end
end
