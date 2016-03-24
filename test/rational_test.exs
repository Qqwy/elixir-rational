defmodule RationalTest do
  use ExUnit.Case
  import Rational
  doctest Rational

  test "definition of <|> operator" do
    assert 1 <|> 2 == %Rational{dividend: 1, divisor: 2}
  end

  test "reject _ <|> 0" do
    assert_raise ArithmeticError, fn ->  1 <|> 0 end
    assert_raise ArithmeticError, fn ->  1234 <|> 0 end
  end

  test "inspect protocol" do 
    assert Inspect.inspect(1 <|> 2, []) == "1 <|> 2"
  end

  
end
