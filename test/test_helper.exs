ExUnit.start()

require ExUnitProperties

defmodule TestHelper do
  def rational_generator do
    ExUnitProperties.gen all  numerator <- StreamData.integer,
      denominator <- StreamData.integer,
      denominator != 0 do
      Ratio.new(numerator, denominator)
    end
  end
end
