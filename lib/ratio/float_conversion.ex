defmodule Ratio.FloatConversion do
  import Ratio, only: [<|>: 2]

  @doc """
  Converts a float to a rational number.
  Because base-2 floats cannot represent all base-10 fractions properly, the results might be different from what you might expect.
  See [The Perils of Floating Point](http://www.lahey.com/float.htm) for more information about this.

  ## Examples

      iex> Ratio.FloatConversion.float_to_rational(10.0)
      10 <|> 1
      iex> Ratio.FloatConversion.float_to_rational(13.5)
      27 <|> 2
      iex> Ratio.FloatConversion.float_to_rational(1.1)
      2476979795053773 <|> 2251799813685248
  """

  def float_to_rational(float) do
    {numerator, denominator} = Float.ratio(float)
    numerator <|> denominator
  end
end
