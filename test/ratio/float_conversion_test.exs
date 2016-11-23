defmodule Ratio.FloatConversionTest do
  use ExUnit.Case, async: true

  # use Ratio coerces negative floats to Ratios, so the below test needs to be run outside the Ratio.FloatConversion
  # module.
  test "float conversion for negative numbers" do
    assert %Ratio{numerator: -11, denominator: 10} == Ratio.FloatConversion.float_to_rational(-1.1, 3)
  end
end
