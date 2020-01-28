if Code.ensure_loaded?(Decimal) do
  defmodule Ratio.DecimalConversion do
    use Ratio

    def decimal_to_rational(%Decimal{coef: coef, exp: 0}) do
      Ratio.new(coef, 1)
    end

    def decimal_to_rational(%Decimal{exp: exp} = decimal) when exp < 0 do
      %Decimal{coef: coef, exp: exp, sign: sign} = normalize_decimal(decimal)

      {integer, decimal} =
        coef
        |> Integer.to_string
        |> String.split_at(exp)

      decimal_len = String.length(integer)
      numerator = Ratio.pow(10, decimal_len)
      integer = String.to_integer(integer)
      decimal = String.to_integer(decimal)

      (sign * (integer * numerator + decimal)) <|> numerator
    end

    def decimal_to_rational(%Decimal{} = decimal) do
      %Decimal{coef: coef, exp: exp, sign: sign} = normalize_decimal(decimal)
      (sign * (coef * Ratio.pow(10, exp))) <|> 1
    end

    if function_exported?(Decimal, :normalize, 1) do
      defp normalize_decimal(decimal) do
        Decimal.normalize(decimal)
      end
    else
      defp normalize_decimal(decimal) do
        Decimal.reduce(decimal)
      end
    end
  end

end