defmodule Rational do
  import Kernel, except: [div: 2, *: 2, abs: 1]

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [div: 2, *: 2, abs: 1]
      import Rational
    end
  end


  @doc """
  A Rational number is defined as a dividend and a divisor.
  Both the dividend and the divisor are integers.
  """
  defstruct dividend: 1, divisor: 1
  @type t :: %Rational{dividend: integer(), divisor: pos_integer()}

  @doc """
  Creates a new Rational number.
  This number is simplified to the most basic form automatically.

  Note that it is recommended to use integer numbers for the dividend and the divisor.
  Floats will be rounded to the nearest integer.

  Rational numbers with a `0` as divisor are not allowed.

  ## Examples

      iex> 1 <|> 2
      1 <|> 2
      iex> 100 <|> 300
      1 <|> 3
      iex> 1.5 <|> 4
      1 <|> 2
  """
  def dividend <|> divisor

  def _dividend <|> 0 do
    raise ArithmeticError
  end

  def dividend <|> divisor when is_integer(dividend) and is_integer(divisor) do 
    %Rational{dividend: dividend, divisor: divisor}
    |> simplify
  end

  def dividend <|> divisor when is_float(dividend) or is_float(divisor) do
    round(dividend) <|> round(divisor)
  end

  @doc """
  Prefix-version of `dividend <|> divisor`.
  Useful when `<|>` is not available (for instance, when already in use by another module)
  
  """
  def new(dividend, divisor), do: dividend <|> divisor


  @doc """
  Returns the absolute version of the given number or Rational.

  ## Examples

      iex>Rational.abs(-5 <|> 2)
      5 <|> 2
  """
  def abs(number) when is_number(number), do: Kernel.abs(number)
  def abs(%Rational{dividend: dividend, divisor: divisor}), do: Kernel.abs(dividend) <|> divisor


  @doc """
  Multiplies two numbers. (one or both of which might be Rationals)
  
      iex> Rational.mul(2 <|> 3, 10)
      20 <|> 3
      iex> Rational.mul( 1 <|> 3, 1 <|> 2)
      1 <|> 6
  """
  def mul(rational, number_or_rational)

  def mul(%Rational{dividend: dividend, divisor: divisor}, number) when is_number(number) do
    Kernel.*(dividend, number) <|> (divisor)
  end

  def mul(number, %Rational{dividend: dividend, divisor: divisor}) when is_number(number) do
    Kernel.*(dividend, number) <|> (divisor)
  end


  def mul(%Rational{dividend: dividend1, divisor: divisor1}, %Rational{dividend: dividend2, divisor: divisor2}) do
    Kernel.*(dividend1, dividend2) <|> Kernel.*(divisor1, divisor2)
  end

  @doc """
  Multiplies two numbers. (one or both of which might be Rationals)

  """
  def a * b

  def a * b when is_number(a) and is_number(b), do: Kernel.*(a, b)

  def _a * _b, do: mul(a, b)

  @doc """
  Divides a Rational by a number (which might be another Rational)
  
  ## Examples

      iex> Rational.div(1 <|> 3, 2)
      1 <|> 6
      iex> Rational.div( 2 <|> 3, 8 <|> 3)
      1 <|> 4
  """
  def div(a, b)
  def div(a, b) when is_number(a) and is_number(b), do: Kernel.div(a, b)

  def div(%Rational{dividend: dividend, divisor: divisor}, number) when is_number(number) do
    dividend <|> Kernel.*(divisor, number)
  end

  def div(%Rational{dividend: dividend1, divisor: divisor1}, %Rational{dividend: dividend2, divisor: divisor2}) do
    Kernel.*(dividend1, divisor2) <|> Kernel.*(divisor1, dividend2)
  end



  @doc """
  Returns a binstring representation of the Rational number.
  If the divisor is `1`, it will be printed as a normal (integer) number.

  ## Examples

      iex> Rational.to_string 10 <|> 7
      "10 <|> 7"
  """
  def to_string(rational)
  def to_string(%Rational{dividend: dividend, divisor: divisor}) when divisor == 1 do
    "#{dividend}"
  end
  def to_string(%Rational{dividend: dividend, divisor: divisor}) do
    "#{dividend} <|> #{divisor}"
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
  defp simplify(%Rational{dividend: dividend, divisor: divisor}) do
    gcdiv = gcd(dividend, divisor)
    %Rational{dividend: Kernel.div(dividend, gcdiv), divisor: Kernel.div(divisor, gcdiv)}
  end


  # Calculates the Greatest Common Divisor of two numbers.
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


