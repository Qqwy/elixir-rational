require Coerce


Coerce.defcoercion(Ratio, Integer) do
  def coerce(ratio, integer) do
    {ratio, Ratio.new(integer)}
  end
end


Coerce.defcoercion(Ratio, Float) do
  def coerce(ratio, float) do
    {ratio, Ratio.new(float)}
  end
end
