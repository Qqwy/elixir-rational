require Coerce

Coerce.defcoercion(Ratio, Decimal) do
  def coerce(ratio, decimal) do
    {ratio, Ratio.DecimalConversion.decimal_to_rational(decimal)}
  end
end
