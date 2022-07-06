defmodule Ratio do
  @vsn "3.0.0"

  import Kernel,
    except: [
      div: 2,
      abs: 1,
      floor: 1,
      ceil: 1,
      trunc: 1
    ]

  @moduledoc """
  This module allows you to use Rational numbers in Elixir, to enable exact calculations with all numbers big and small.

  `Ratio` defines arithmetic and comparison operations to work with rational numbers.

  Usually, you probably want to add the line `import Ratio, only: [<|>: 2]` to your code.

  ## Shorthand operator

  Rational numbers can be written using the operator `<|>` (as in: `1 <|> 2`), which is also how Ratio structs are pretty-printed when inspecting.
  `a <|> b` is a shorthand for `Ratio.new(a, b)`.

  ## Inline Math Operators and Casting

  Ratio interopts with the `Numbers` library:
  If you want to overload Elixir's builtin math operators, you can use `use Numbers, overload_operators: true`.

  This also allows you to pass in a rational number as one argument
  and an integer, float or Decimal (if you have installed the `Decimal` library),
  which are then cast to rational numbers whenever necessary.

  """

  defmacro __using__(_opts) do
    raise """
    Writing `use Ratio` (with or without options) is no longer possible in version 3.

    Instead:

    - To only use the rational number creation shorthand operator, write `import Ratio, only: [<|>: 2]`
    - To override the inline math operators, write `use Numbers, overload_operators: true`. (and see the `Numbers` module/library for more information.)
    """
  end

  @doc """
  A Rational number is defined as a numerator and a denominator.
  Both the numerator and the denominator are integers.
  If you want to match for a rational number, you can do so by matching against this Struct.

  Note that *directly manipulating* the struct, however, is usually a bad idea, as then there are no validity checks, nor wil the rational be simplified.

  Use `Ratio.<|>/2` or `Ratio.new/2` instead.
  """
  defstruct continued_fraction_representation: nil, numerator: 0, denominator: 1

  @type t :: %Ratio{
          continued_fraction_representation: nil | list(integer()),
          numerator: integer(),
          denominator: pos_integer()
        }

  @doc """
  Check to see whether something is a ratioal struct.

  On recent OTP versions that expose `:erlang.map_get/2` this function is guard safe.

  iex> require Ratio
  iex> Ratio.is_rational(1 <|> 2)
  true
  iex> Ratio.is_rational(Ratio.new(10))
  true
  iex> Ratio.is_rational(42)
  false
  iex> Ratio.is_rational(%{})
  false
  iex> Ratio.is_rational("My quick brown fox")
  false
  """
  if function_exported?(:erlang, :map_get, 2) and function_exported?(Kernel, :is_map_key, 2) do
    defguard is_rational(val)
             when is_map(val) and is_map_key(val, :__struct__) and is_struct(val) and
                    :erlang.map_get(:__struct__, val) == __MODULE__
  else
    def is_rational(val)
    def is_rational(%Ratio{}), do: true
    def is_rational(_), do: false
  end

  @doc """
  Creates a new Rational number.
  This number is simplified to the most basic form automatically.

  Rational numbers with a `0` as denominator are not allowed.

  Note that it is recommended to use integer numbers for the numerator and the denominator.

  ## Floats

  *If possible, don't use them.*

  Using Floats for the numerator or denominator is possible, however, because base-2 floats cannot represent all base-10 fractions properly, the results might be different from what you might expect.
  See [The Perils of Floating Point](http://www.lahey.com/float.htm) for more information about this.

  Floats are converted into rationals by using `Float.ratio` (since version 3.0).

  ## Decimals

  To use `Decimal` parameters, the [decimal](https://hex.pm/packages/decimal) library must
  be configured in `mix.exs`.

  ## Examples

      iex> 1 <|> 2
      1 <|> 2
      iex> 100 <|> 300
      1 <|> 3
      iex> 1.5 <|> 4
      3 <|> 8
  """
  def numerator <|> denominator

  def _numerator <|> 0 do
    raise ArithmeticError
  end

  def numerator <|> denominator when is_integer(numerator) and is_integer(denominator) do
    simplify(%Ratio{numerator: numerator, denominator: denominator})
  end

  def numerator <|> denominator when is_float(numerator) do
    div(Ratio.FloatConversion.float_to_rational(numerator), Ratio.new(denominator))
  end

  def numerator <|> denominator when is_float(denominator) do
    div(numerator, Ratio.FloatConversion.float_to_rational(denominator))
  end

  def (numerator = %Ratio{}) <|> (denominator = %Ratio{}) do
    div(numerator, denominator)
  end

  if Code.ensure_loaded?(Decimal) do
    def (numerator = %Decimal{}) <|> (denominator = %Decimal{}) do
      Ratio.DecimalConversion.decimal_to_rational(numerator)
      |> div(Ratio.DecimalConversion.decimal_to_rational(denominator))
    end

    def (numerator = %Decimal{}) <|> denominator when is_float(denominator) do
      Ratio.DecimalConversion.decimal_to_rational(numerator)
      |> div(Ratio.FloatConversion.float_to_rational(denominator))
    end

    def numerator <|> (denominator = %Decimal{}) when is_float(numerator) do
      Ratio.FloatConversion.float_to_rational(numerator)
      |> div(Ratio.DecimalConversion.decimal_to_rational(denominator))
    end

    def (numerator = %Decimal{}) <|> denominator when is_integer(denominator) do
      Ratio.DecimalConversion.decimal_to_rational(numerator)
      |> div(denominator)
    end

    def numerator <|> (denominator = %Decimal{}) when is_integer(numerator) do
      div(Ratio.DecimalConversion.decimal_to_rational(numerator), denominator)
    end
  end

  def numerator <|> (denominator = %Ratio{}) when is_integer(numerator) do
    div(%Ratio{numerator: numerator, denominator: 1}, denominator)
  end

  def (numerator = %Ratio{}) <|> denominator when is_integer(denominator) do
    div(numerator, %Ratio{numerator: 1, denominator: denominator})
  end

  @doc """
  Prefix-version of `numerator <|> denominator`.
  Useful when `<|>` is not available (for instance, when already in use by another module)

  Not imported when calling `use Ratio`, so always call it as `Ratio.new(a, b)`

  To use `Decimal` parameters, the [decimal](https://hex.pm/packages/decimal) library must
  be configured in `mix.exs`.

  ## Examples

      iex> Ratio.new(1, 2)
      1 <|> 2
      iex> Ratio.new(100, 300)
      1 <|> 3

  """
  def new(numerator, denominator \\ 1)

  if Code.ensure_loaded?(Decimal) do
    def new(%Decimal{} = decimal, 1) do
      Ratio.DecimalConversion.decimal_to_rational(decimal)
    end

    def new(%Decimal{} = numerator, %Decimal{} = denominator) do
      Ratio.DecimalConversion.decimal_to_rational(numerator)
      <|> Ratio.DecimalConversion.decimal_to_rational(denominator)
    end

    def new(numerator, %Decimal{} = denominator) do
      numerator <|> Ratio.DecimalConversion.decimal_to_rational(denominator)
    end
  end

  def new(numerator, denominator) do
    numerator <|> denominator
  end

  @doc """
  Returns the absolute version of the given number (which might be an integer, float or Rational).

  ## Examples

      iex>Ratio.abs(-5 <|> 2)
      5 <|> 2
  """
  def abs(number) when is_number(number), do: Kernel.abs(number)

  def abs(%Ratio{numerator: numerator, denominator: denominator}),
    do: Kernel.abs(numerator) <|> denominator

  @doc """
  Returns the sign of the given number (which might be an integer, float or Rational)

  This is:

   - 1 if the number is positive.
   - -1 if the number is negative.
   - 0 if the number is zero.

  """
  def sign(%Ratio{numerator: numerator}) when Kernel.>(numerator, 0), do: 1
  def sign(%Ratio{numerator: numerator}) when Kernel.<(numerator, 0), do: Kernel.-(1)
  def sign(number) when is_number(number) and Kernel.>(number, 0), do: 1
  def sign(number) when is_number(number) and Kernel.<(number, 0), do: Kernel.-(1)
  def sign(number) when is_number(number), do: 0

  @doc """
  Converts the passed *number* as a Rational number, and extracts its denominator.
  For integers returns the passed number itself.

  """
  def numerator(number) when is_integer(number), do: number

  def numerator(number) when is_float(number),
    do: numerator(Ratio.FloatConversion.float_to_rational(number))

  def numerator(%Ratio{numerator: numerator}), do: numerator

  @doc """
  Treats the passed *number* as a Rational number, and extracts its denominator.
  For integers, returns `1`.
  """
  def denominator(number) when is_number(number), do: 1
  def denominator(%Ratio{denominator: denominator}), do: denominator

  @doc """
  Adds two rational numbers.
  """
  def add(a, b)

  def add(%Ratio{numerator: a, denominator: lcm}, %Ratio{numerator: c, denominator: lcm}) do
    Kernel.+(a, c) <|> lcm
  end

  def add(%Ratio{numerator: a, denominator: b}, %Ratio{numerator: c, denominator: d}) do
    Kernel.+(a * d, c * b) <|> (b * d)
  end

  @doc """
  Subtracts the rational number *b* from the rational number *a*.
  """
  def sub(a, b), do: add(a, minus(b))

  @doc """
  Negates the given rational number.

  ## Examples

  iex> Ratio.minus(5 <|> 3)
  -5 <|> 3
  """
  def minus(%Ratio{numerator: numerator, denominator: denominator}) do
    {continued_fraction, _} =
      get_continued_fraction_representation(Kernel.-(numerator), denominator)

    %Ratio{
      numerator: Kernel.-(numerator),
      denominator: denominator,
      continued_fraction_representation: continued_fraction
    }
  end

  @doc """
  Multiplies two rational numbers.

  # Examples

  iex> Ratio.mult( 1 <|> 3, 1 <|> 2)
  1 <|> 6
  """
  def mult(number1, number2)

  def mult(%Ratio{numerator: numerator1, denominator: denominator1}, %Ratio{
        numerator: numerator2,
        denominator: denominator2
      }) do
    Kernel.*(numerator1, numerator2) <|> Kernel.*(denominator1, denominator2)
  end

  @doc """
  Divides the rational number *a* by the rational number *b*.

  ## Examples

  iex> Ratio.div(2 <|> 3, 8 <|> 5)
  5 <|> 12

  """
  def div(a, b)

  def div(%Ratio{numerator: numerator1, denominator: denominator1}, %Ratio{
        numerator: numerator2,
        denominator: denominator2
      }) do
    Kernel.*(numerator1, denominator2) <|> Kernel.*(denominator1, numerator2)
  end

  defmodule ComparisonError do
    defexception message: "These things cannot be compared."
  end

  @doc """
  Compares two rational numbers, returning `:lt`, `:eg` or `:gt`
  depending on whether *a* is less than, equal to or greater than *b*, respectively.

  This function is able to compare rational numbers against integers or floats as well.

  This function accepts other types as input as well, comparing them using Erlang's Term Ordering.
  This is mostly useful if you have a collection that contains other kinds of numbers (builtin integers or floats) as well.

  """
  # TODO enhance this function to work with other number types?
  def compare(%Ratio{numerator: a, denominator: b}, %Ratio{numerator: c, denominator: d}) do
    compare(Kernel.*(a, d), Kernel.*(b, c))
  end

  def compare(%Ratio{numerator: numerator, denominator: denominator}, b) do
    compare(numerator, Kernel.*(b, denominator))
  end

  def compare(a, %Ratio{numerator: numerator, denominator: denominator}) do
    compare(Kernel.*(a, denominator), numerator)
  end

  # Fallback using the builting Erlang term ordering.
  def compare(a, b) do
    case {a, b} do
      {a, b} when a > b -> :gt
      {a, b} when a < b -> :lt
      _ -> :eq
    end
  end

  @doc """
  True if *a* is equal to *b*
  """
  def eq?(a, b), do: compare(a, b) |> Kernel.==(:eq)

  @doc """
  True if *a* is larger than or equal to *b*
  """
  def gt?(a, b), do: compare(a, b) |> Kernel.==(:gt)

  @doc """
  True if *a* is smaller than *b*
  """
  def lt?(a, b), do: compare(a, b) |> Kernel.==(:lt)

  @doc """
  True if *a* is larger than or equal to *b*
  """
  def gte?(a, b), do: compare(a, b) in [:eq, :gt]

  @doc """
  True if *a* is smaller than or equal to *b*
  """
  def lte?(a, b), do: compare(a, b) in [:lt, :eq]

  @doc """
  True if *a* is equal to *b*?
  """
  def equal?(a, b), do: compare(a, b) |> Kernel.==(:eq)

  @doc """
  returns *x* to the *n* th power.

  *x* is allowed to be an integer, rational or float (in the last case, this is first converted to a rational).

  Will give the answer as a rational number when applicable.
  Note that the exponent *n* is only allowed to be an integer.

  (so it is not possible to compute roots using this function.)

  ## Examples

      iex> Ratio.pow(Ratio.new(2), 4)
      16 <|> 1
      iex> Ratio.pow(Ratio.new(2), -4)
      1 <|> 16
      iex> Ratio.pow(3 <|> 2, 10)
      59049 <|> 1024
      iex> Ratio.pow(Ratio.new(10), 0)
      1 <|> 1
  """
  @spec pow(number() | Ratio.t(), pos_integer()) :: Ratio.t()
  def pow(x, n)

  # Convert Float to Rational.
  # def pow(x, n) when is_float(x), do: pow(Ratio.FloatConversion.float_to_rational(x), n)

  # Small powers
  def pow(%__MODULE__{}, 0), do: Ratio.new(1)
  def pow(x = %__MODULE__{}, 1), do: x
  def pow(x = %__MODULE__{}, 2), do: Ratio.mult(x, x)
  def pow(x = %__MODULE__{}, 3), do: Ratio.mult(Ratio.mult(x, x), x)
  def pow(x = %__MODULE__{}, n) when is_integer(n), do: do_pow(x, n)

  # Exponentiation By Squaring.
  defp do_pow(x, n, y \\ 1)
  defp do_pow(_x, 0, y), do: y
  defp do_pow(x, 1, y), do: Numbers.mult(x, y)
  defp do_pow(x, n, y) when Kernel.<(n, 0), do: do_pow(1 <|> x, Kernel.-(n), y)

  defp do_pow(x, n, y) when rem(n, 2) |> Kernel.==(0) do
    do_pow(Ratio.mult(x, x), Kernel.div(n, 2), y)
  end

  defp do_pow(x, n, y) do
    do_pow(Ratio.mult(x, x), Kernel.div(n - 1, 2), Numbers.mult(x, y))
  end

  @doc """
  Converts the given *number* to a Float. As floats do not have arbitrary precision, this operation is generally not reversible.

  Not imported when calling `use Ratio`, so always call it as `Rational.to_float(number)`
  """
  @spec to_float(Ratio.t() | number) :: float
  def to_float(%Ratio{numerator: numerator, denominator: denominator}),
    do: Kernel./(numerator, denominator)

  def to_float(number), do: :erlang.float(number)

  @doc """
  Returns a tuple, where the first element is the result of `to_float(number)` and
  the second is a conversion error.

  The conversion error is calculated by subtracting the original number from the
  conversion result.

  ## Examples

      iex> Ratio.to_float_error(Ratio.new(1, 2))
      {0.5, 0 <|> 1}
      iex> Ratio.to_float_error(Ratio.new(2, 3))
      {0.6666666666666666, -1 <|> 27021597764222976}
  """
  @spec to_float_error(t | number) :: {float, error} when error: t | number
  def to_float_error(number) do
    float = to_float(number)
    error = Ratio.sub(Ratio.new(float), number)
    {float, error}
  end

  @doc """
  Returns a binstring representation of the Rational number.
  If the denominator is `1` it will still be printed in the `a <|> 1` format.

  ## Examples

      iex> Ratio.to_string 10 <|> 7
      "10 <|> 7"
      iex> Ratio.to_string 10 <|> 2
      "5 <|> 1"
  """
  def to_string(rational)

  def to_string(%Ratio{numerator: numerator, denominator: denominator}) do
    "#{numerator} <|> #{denominator}"
  end

  defimpl String.Chars, for: Ratio do
    def to_string(rational) do
      Ratio.to_string(rational)
    end
  end

  defimpl Inspect, for: Ratio do
    def inspect(rational, _) do
      Ratio.to_string(rational)
    end
  end

  # Simplifies the Rational to its most basic form.
  # Which might result in an integer.
  # Ensures that a `-` is only kept in the numerator.
  defp simplify(rational)

  defp simplify(%Ratio{numerator: numerator, denominator: denominator}) do
    {continued_fraction, gcdiv} = get_continued_fraction_representation(numerator, denominator)
    new_denominator = Kernel.div(denominator, gcdiv)
    {new_denominator, numerator} = normalize_denom_num(new_denominator, numerator)

    # if new_denominator == 1 do
    #   Kernel.div(numerator, gcdiv)
    # else
    %Ratio{
      continued_fraction_representation: continued_fraction,
      numerator: Kernel.div(numerator, gcdiv),
      denominator: new_denominator
    }

    # end
  end

  defp normalize_denom_num(denominator, numerator) do
    if denominator < 0 do
      {Kernel.-(denominator), Kernel.-(numerator)}
    else
      {denominator, numerator}
    end
  end

  # Returns the continued fraction representation of a rational with 'a' being it's numerator and 'b' being it's denominator, along with Greatest Common Divisor of 'a' and 'b'.
  def get_continued_fraction_representation(a, b) do
    sign = sign(a) * sign(b)
    {continued_fraction, gcdiv} = get_continued_fraction_representation(a, b, 0)
    {[sign | continued_fraction], gcdiv}
  end

  defp get_continued_fraction_representation(a, 0, _depth), do: {[], abs(a)}
  defp get_continued_fraction_representation(0, b, _depth), do: {[0], abs(b)}

  defp get_continued_fraction_representation(a, b, depth) do
    {continued_fraction, gcdiv} =
      get_continued_fraction_representation(b, Kernel.rem(a, b), depth + 1)

    sign = if rem(depth, 2) == 0, do: 1, else: -1
    {[sign * Kernel.div(a, b) | continued_fraction], gcdiv}
  end

  @doc """
  Rounds a number (rational, integer or float) to the largest whole number less than or equal to num.
  For negative numbers, this means we are rounding towards negative infinity.


  iex> Ratio.floor(Ratio.new(1, 2))
  0
  iex> Ratio.floor(Ratio.new(5, 4))
  1
  iex> Ratio.floor(Ratio.new(-3, 2))
  -2

  """
  def floor(num) when is_integer(num), do: num
  def floor(num) when is_float(num), do: Float.floor(num)

  def floor(%Ratio{numerator: numerator, denominator: denominator}),
    do: Integer.floor_div(numerator, denominator)

  @doc """
  Rounds a number (rational, integer or float) to the largest whole number larger than or equal to num.
  For negative numbers, this means we are rounding towards negative infinity.


  iex> Ratio.ceil(Ratio.new(1, 2))
  1
  iex> Ratio.ceil(Ratio.new(5, 4))
  2
  iex> Ratio.ceil(Ratio.new(-3, 2))
  -1
  iex> Ratio.ceil(Ratio.new(400))
  400

  """
  def ceil(num) when is_float(num), do: Float.ceil(num)
  def ceil(num) when is_integer(num), do: num

  def ceil(num = %Ratio{numerator: numerator, denominator: denominator}) do
    floor = Ratio.floor(num)

    if rem(numerator, denominator) == 0 do
      floor
    else
      floor + 1
    end
  end

  @doc """
  Returns the integer part of number.

  ## Examples

      iex> Ratio.trunc(1.7)
      1
      iex> Ratio.trunc(-1.7)
      -1
      iex> Ratio.trunc(3)
      3
      iex> Ratio.trunc(Ratio.new(5, 2))
      2
  """
  @spec trunc(t | number) :: integer
  def trunc(num) when is_integer(num), do: num
  def trunc(num) when is_float(num), do: Kernel.trunc(num)

  def trunc(%Ratio{numerator: numerator, denominator: denominator}) do
    Kernel.div(numerator, denominator)
  end
end
