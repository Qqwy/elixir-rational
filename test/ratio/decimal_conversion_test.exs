if Code.ensure_loaded?(Decimal) do
  defmodule Ratio.DecimalConversionTest do
    use ExUnit.Case, async: true
    use Ratio
    alias Ratio.DecimalConversion

    describe "decimal_to_rational/1" do
      test "decimal conversion of negative numbers" do
        decimal_and_expected = [
          {Decimal.new("-1230"), -1230 <|> 1},
          {Decimal.new("-123"), -123 <|> 1},
          {Decimal.new("-12.3"), -123 <|> 10},
          {Decimal.new("-1.23"), -123 <|> 100},
          {Decimal.new("-0.123"), -123 <|> 1000},
          {Decimal.new("-0.0123"), -123 <|> 10000}
        ]

        assert {^decimal_and_expected, []} =
                 Enum.split_with(decimal_and_expected, fn {decimal, expected} ->
                   DecimalConversion.decimal_to_rational(decimal) == expected
                 end)
      end

      test "decimal conversion of positive numbers" do
        decimal_and_expected = [
          {Decimal.new("1230"), 1230 <|> 1},
          {Decimal.new("123"), 123 <|> 1},
          {Decimal.new("12.3"), 123 <|> 10},
          {Decimal.new("1.23"), 123 <|> 100},
          {Decimal.new("0.123"), 123 <|> 1000},
          {Decimal.new("0.0123"), 123 <|> 10000}
        ]

        assert {^decimal_and_expected, []} =
                 Enum.split_with(decimal_and_expected, fn {decimal, expected} ->
                   DecimalConversion.decimal_to_rational(decimal) == expected
                 end)
      end
    end
  end
end
