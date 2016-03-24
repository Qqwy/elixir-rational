# TODO: add @specs.
defmodule Rational do
  import Kernel, except: [div: 2, *: 2, /: 2, abs: 1]

  # TODO: Add an option to not import inline operators.
  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [div: 2, *: 2, /: 2, abs: 1]
      import Rational
    end
  end


  @doc """
  A Rational number is defined as a numerator and a denominator.
  Both the numerator and the denominator are integers.
  """
  defstruct numerator: 1, denominator: 1
  @type t :: %Rational{numerator: integer(), denominator: pos_integer()}

  @doc """
  Creates a new Rational number.
  This number is simplified to the most basic form automatically.
  If the most basic form has the format `_ <|> 1`, it is returned in integer form.

  Note that it is recommended to use integer numbers for the numerator and the denominator.
  Floats will be rounded to the nearest integer.

  Rational numbers with a `0` as denominator are not allowed.

  ## Examples

      iex> 1 <|> 2
      1 <|> 2
      iex> 100 <|> 300
      1 <|> 3
      iex> 1.5 <|> 4
      1 <|> 2
  """
  def numerator <|> denominator

  def _numerator <|> 0 do
    raise ArithmeticError
  end

  def numerator <|> denominator when is_integer(numerator) and is_integer(denominator) do 
    %Rational{numerator: numerator, denominator: denominator}
    |> simplify
    |> remove_denominator_if_integer
  end

  def numerator <|> denominator when is_float(numerator) or is_float(denominator) do
    round(numerator) <|> round(denominator)
  end

  @doc """
  Prefix-version of `numerator <|> denominator`.
  Useful when `<|>` is not available (for instance, when already in use by another module)
  
  """
  def new(numerator, denominator), do: numerator <|> denominator


  @doc """
  Returns the absolute version of the given number or Rational.

  ## Examples

      iex>Rational.abs(-5 <|> 2)
      5 <|> 2
  """
  def abs(number) when is_number(number), do: Kernel.abs(number)
  def abs(%Rational{numerator: numerator, denominator: denominator}), do: Kernel.abs(numerator) <|> denominator

  @doc """
  Returns the sign of the number Rational
 
  This is:
  
   - 1 if the number is positive.
   - -1 if the number is negative.
   - 0 if the number is zero.

  """
  def sign(%Rational{numerator: numerator}) when numerator > 0, do: 1
  def sign(%Rational{numerator: numerator}) when numerator < 0, do: -1
  def sign(number) when is_number(number) and number > 0, do: 1
  def sign(number) when is_number(number) and number < 0, do: -1
  def sign(number) when is_number(number), do: 0



  @doc """
  Multiplies two numbers. (one or both of which might be Rationals)
  
      iex> Rational.mul(2 <|> 3, 10)
      20 <|> 3
      iex> Rational.mul( 1 <|> 3, 1 <|> 2)
      1 <|> 6
  """
  def mul(rational, number_or_rational)

  def mul(%Rational{numerator: numerator, denominator: denominator}, number) when is_number(number) do
    Kernel.*(numerator, number) <|> (denominator)
  end

  def mul(number, %Rational{numerator: numerator, denominator: denominator}) when is_number(number) do
    Kernel.*(numerator, number) <|> (denominator)
  end


  def mul(%Rational{numerator: numerator1, denominator: denominator1}, %Rational{numerator: numerator2, denominator: denominator2}) do
    Kernel.*(numerator1, numerator2) <|> Kernel.*(denominator1, denominator2)
  end

  @doc """
  Multiplies two numbers. (one or both of which might be Rationals)

  """
  def a * b

  def a * b when is_number(a) and is_number(b), do: Kernel.*(a, b)

  def a * b, do: mul(a, b)

  @doc """
  Divides a Rational by a number (which might be another Rational)

  Dividing a number by a float returns a float.
  Dividing a number by an integer returns a Rational.
  Dividing a number by a Rational also returns a Rational.

  
  ## Examples

      iex> Rational.div(1 <|> 3, 2)
      1 <|> 6
      iex> Rational.div( 2 <|> 3, 8 <|> 3)
      1 <|> 4
  """
  def div(a, b)
  def div(a, b) when is_number(a) and is_number(b), do: Kernel.div(a, b)

  def div(%Rational{numerator: numerator, denominator: denominator}, number) when is_number(number) do
    numerator <|> Kernel.*(denominator, number)
  end

  # 6 / (2 <|> 3) == 6 * (3 <|> 2)
  def div(number, %Rational{numerator: numerator, denominator: denominator}) when is_number(number) do
    mul(number, denominator <|> numerator)
  end


  def div(%Rational{numerator: numerator1, denominator: denominator1}, %Rational{numerator: numerator2, denominator: denominator2}) do
    Kernel.*(numerator1, denominator2) <|> Kernel.*(denominator1, numerator2)
  end

  @doc """
  Divides a number by another number.

  Dividing a number by a float returns a float.
  Dividing a number by an integer returns a Rational.
  Dividing a number by a Rational also returns a Rational.
  """
  def a / b

  # Do not modify float-division behaviour.
  def a / b when is_float(b) and is_number(a), do:  Kernel./(a, b)
  
  def a / b when is_number(a) and is_integer(b), do:  a <|> b
  def a / b, do: div(a, b)




  @doc """
  Returns a binstring representation of the Rational number.
  If the denominator is `1`, it will be printed as a normal (integer) number.

  ## Examples

      iex> Rational.to_string 10 <|> 7
      "10 <|> 7"
  """
  def to_string(rational)
  def to_string(%Rational{numerator: numerator, denominator: denominator}) when denominator == 1 do
    "#{numerator}"
  end
  def to_string(%Rational{numerator: numerator, denominator: denominator}) do
    "#{numerator} <|> #{denominator}"
  end

  defimpl String.Chars, for: Rational do
    def to_string(rational) do
      Rational.to_string(rational)    
    end
  end

  defimpl Inspect, for: Rational do
    def inspect(rational, _) do
      Rational.to_string(rational)    
    end
  end


  # Simplifies the Rational to its most basic form.
  defp simplify(rational)

  defp simplify(%Rational{numerator: numerator, denominator: denominator}) do
    gcdiv = gcd(numerator, denominator)
    new_denominator = Kernel.div(denominator, gcdiv)
    if new_denominator == 1 do
      numerator
    else
      %Rational{numerator: Kernel.div(numerator, gcdiv), denominator: new_denominator}
    end
  end

  # Returns an integer if the result is of the form _ <|> 1
  defp remove_denominator_if_integer(rational)
  defp remove_denominator_if_integer(%Rational{numerator: numerator, denominator: 1}), do: numerator
  defp remove_denominator_if_integer(rational), do: rational


  # Calculates the Greatest Common denominator of two numbers.
  defp gcd(a, 0), do: abs(a)
  
  defp gcd(0, b), do: abs(b)
  defp gcd(a, b), do: gcd(b, Kernel.rem(a,b))

  # Calculates the Least Common Multiple of two numbers.
  defp lcm(a, b)

  defp lcm(0, 0), do: 0
  defp lcm(a, b) do
    Kernel.div(Kernel.*(a, b), gcd(a, b))
  end

end


