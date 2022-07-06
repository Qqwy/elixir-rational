defmodule Ratio.FloatConversionTest do
  use ExUnit.Case, async: true

  # use Ratio coerces negative floats to Ratios, so the below test needs to be run outside the Ratio.FloatConversion
  # module.
  test "float conversion for negative numbers" do
    assert %Ratio{
             numerator: -2_476_979_795_053_773,
             denominator: 2_251_799_813_685_248,
             continued_fraction_representation: [-1, -1, 9, -1, 112_589_990_684_261, -2]
           } ==
             Ratio.FloatConversion.float_to_rational(-1.1)
  end
end
