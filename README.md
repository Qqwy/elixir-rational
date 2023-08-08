# Ratio


[![hex.pm version](https://img.shields.io/hexpm/v/ratio.svg)](https://hex.pm/packages/ratio)
[![Documentation](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/ratio/index.html)
[![ci](https://github.com/Qqwy/elixir-rational/actions/workflows/ci.yml/badge.svg)](https://github.com/Qqwy/elixir-rational/actions/workflows/ci.yml)

This library allows you to use Rational numbers in Elixir, to enable exact calculations with all numbers big and small.

Ratio follows the Numeric behaviour from [Numbers](https://github.com/Qqwy/elixir_number), and can therefore be used in combination with any data type that uses Numbers (such as [Tensor](https://hex.pm/packages/tensor) and [ComplexNum](https://github.com/Qqwy/elixir_complex_num)).

## Using Ratio

`Ratio` defines arithmetic and comparison operations to work with rational numbers.

Rational numbers can be created by using `Ratio.new/2`,
or by calling mathematical operators where one of the two operands is already a rational number.


### Shorthand infix construction operator

Since version 4.0, `Ratio` no longer defines an infix operator to create rational numbers.
Instead, rational numbers are made using `Ratio.new`,
and as the output from using an existing `Ratio` struct with a mathematical operation.

If you do want to use an infix operator such as
`<~>` (supported in all Elixir versions)
or `<|>` (deprecated in Elixir v1.14, the default of older versions of the `Ratio` library)

you can add the following one-liner to the module(s) in which you want to use it:

```elixir
defdelegate numerator <~> denominator, to: Ratio, as: :new
```

### Basic functionality

Rational numbers can be manipulated using the functions in the [`Ratio`](https://hexdocs.pm/ratio/Ratio.html) module.

```elixir
iex> Ratio.mult(Ratio.new(1, 3), Ratio.new(1, 2))
Ratio.new(1, 6)
iex> Ratio.div(Ratio.new(2, 3), Ratio.new(8, 5))
Ratio.new(5, 12)
iex> Ratio.pow(Ratio.new(2), 4)
Ratio.new(16, 1)
```

The Ratio module also contains:
- a guard-safe `is_rational/1` check.
- a `compare/2` function for use with e.g. `Enum.sort`.
- `to_float/1` to (lossly) convert a rational into a float.

### Inline Math Operators and Casting

Ratio interopts with the [`Numbers`](https://github.com/Qqwy/elixir-number) library:
If you want to overload Elixir's builtin math operators, 
you can add `use Numbers, overload_operators: true` to your module.

This also allows you to pass in a rational number as one argument
and an integer, float or Decimal (if you have installed the `Decimal` library),
which are then cast to rational numbers whenever necessary:

``` elixir
defmodule IDoAlotOfMathHere do
  defdelegate numerator <~> denominator, to: Ratio, as: :new
  use Numbers, overload_operators: true

  def calculate(input) do
     num = input <~> 2
     result = num * 2 + (3 <~> 4) * 5.0
     result / 2
  end
end

```

``` elixir
iex> IDoAlotOfMathHere.calculate(42)
Ratio.new(183, 8)
```


## Installation

  The package can be installed from hex, by adding `:ratio` to your list of dependencies in `mix.exs`:

        def deps do
          [
            {:ratio, "~> 4.0"}
          ]
        end



## Changelog
- 4.0.0 - 
  - Remove infix operator `<|>` as its usage is deprecated in Elixir v1.14. This is a backwards-incompatible change. If you want to use the old syntax with the new version, add `defdelegate num <|> denom, to: Ratio, as: :new` to your module. Alternatively, you might want to use the not-deprecated `<~>` operator for this instead.
  - Switch the `Inspect` implementation to use the form `Ratio.new(10, 20)` instead of `10 <|> 20`, related to above. This is also a backwards-incompatible change.
  - Remove implementation of `String.Chars`, as the earlier implementation was not a (non-programmer) human-readable format.
  - Ensure that the right-hand-side operand of calls to `Ratio.{add, sub, mult, div}/2` is allowed to be an integer for ease of use and backwards compatibility. Thank you for noticing this problem, @kipcole9 ! (c.f. #111)
- 3.0.2 - 
  - Fixes: A bug with `<|>` when the numerator was a rational and the denuminator an integer. (c.f. #104) Thank you, @varsill!
- 3.0.1 -
  - Fixes:
    - Problem where `Ratio.ceil/1` would be off-by-one (c.f. #89). Thank you, @Hajto!
    - Problem where `Ratio.pow/2` would return an integer rather than a new Ratio.(c.f. #100). Thank you, @speeddragon!
- 3.0.0 - 
  - All operators except `<|>` are removed from Ratio. Instead, the operators defined by [`Numbers`](https://github.com/Qqwy/elixir-number) (which `Ratio` depends on) can be used, by adding `use Numbers, overload_operators: true` to your modules. (c.f. #34)
  - All math-based functions expect and return `Ratio` structs (rather than also working on integers and returning integers sometimes if the output turned out to be a whole number).  (c.f. #43)
    This makes the code more efficient and more clear for users.
    - Ratio structs representing whole numbers are no longer implicitly converted 'back' to integers, as this behaviour was confusing. (c.f. #28)
    - If conversion to/from other number-like types is really desired, 
      use the automatic conversions provided by `Ratio.new`, `<|>` 
      or (a bit slower but more general) the math functions exposed by [`Numbers`](https://github.com/Qqwy/elixir-number).
      Ratio ships with implementations of `Coerce.defcoercion` for Integer -> Ratio, Float -> Ratio and Decimal -> Ratio.
  - `is_rational?/1` is replaced with the guard-safe `is_rational/1` (only exported on Erlang versions where `:erlang.map_get/2` is available, i.e. >= OTP 21.0.) (c.f. #37)
  - `Float.ratio/1` is now used to convert floats into `Ratio` structs, rather than maintaining a hand-written version of this logic. (c.f #46) Thank you, @marcinwasowicz !
  - A lot of property-based tests have been added to get some level of confidence of the correctness of the library's operations.
- 2.4.2 Uses `extra_applications` in `mix.exs` to silence warnings in Elixir 1.11 and onwards.
- 2.4.1 Fixes a bug in the decimal conversion implementation where certain decimals were not converted properly. Thank you, @iterateNZ!
- 2.4.0 Adds optional support for automatic conversion from [Decimal](https://github.com/ericmj/decimal)s. Thank you, @kipcole !
- 2.3.1 Removes spurious printing statement in `Rational.FloatConversion` that would output a line of text at compile-time. Fixes support for Numbers v5+ which was broken.
- 2.3.0 Adds `trunc` and `to_floor_error` functions.
- 2.1.1 Fixes implementation of `floor` and `ceil` which was counter-intuitive for negative numbers (it now correctly rounds towards negative infinity). 
  - Drops support for Elixir versions older than 1.4, because of use of `Integer.floor_div`.
  - First version to support new Erlang versions (20 and onward) that have native `floor` and `ceil` functions.
- 2.1.0 Adds optional overloaded comparison operators.
- 2.0.0 Breaking change: Brought `Ratio.compare/2` in line with Elixir's comparison function guideline, to return `:lt | :eq | :gt`. (This used to be `-1 | 0 | 1`).
- 1.2.9 Improved documentation. (Thanks, @morontt!)
- 1.2.8 Adding `:numbers` to the `applications:` list, to ensure that no warnings are thrown when building releases on Elixir < 1.4.0.
- 1.2.6, 1.2.7 Improving documentation.
- 1.2.5 added `ceil/1` and `floor/1`.
- 1.2.4 Fixes Elixir 1.4 warnings in the `mix.exs` file.
- 1.2.3 Upgraded version of the `Numbers` dependency to 2.0.
- 1.2.2 Added default argument to `Ratio.new/2`, to follow the Numeric behaviour fully, and added `Ratio.minus/1` as alias for `Ratio.negate/1` for the same reason.
- 1.2.0 Changed name of `Ratio.mul/2` to `Ratio.mult/2`, to avoid ambiguety, and to allow incorporation with `Numbers`. Deprecation Warning was added to using `Ratio.mul/2`.
- 1.1.1 Negative floats are now converted correctly.
- 1.1.0 Elixir 1.3 compliance (Statefree if/else/catch clauses, etc.)
- 1.0.0 Proper `__using__` macro, with more readable option names. Stable release.
- 0.6.0 First public release
- 0.0.1 First features


## Difference with the 'rational' library

Observant readers might notice that there also is a '[rational](https://hex.pm/packages/rational)' library in Hex.pm. The design idea between that library vs. this one is a bit different: `Ratio` hides the internal data representation as much as possible, and numbers are therefore only created using `Ratio.new/2`. This has as mayor advantage that the internal representation is always correct and simplified.

The Ratio library also (optionally) overrides (by virtue of the `Numbers` library) the built-in math operations `+, -, *, /, div, abs` so they work with combinations of integers, floats and rationals.

Finally, Ratio follows the Numeric behaviour, which means that it can be used with any data types that follow [Numbers](https://github.com/Qqwy/elixir_number).
