# Ratio


[![hex.pm version](https://img.shields.io/hexpm/v/ratio.svg)](https://hex.pm/packages/ratio)
[![Build Status](https://travis-ci.org/Qqwy/elixir-rational.svg?branch=master)](https://travis-ci.org/Qqwy/elixir-rational)


This library allows you to use Rational numbers in Elixir, to enable exact calculations with all numbers big and small.


## Some Examples

Rationals are constructed using `numerator <|> denomerator` (or, if you don't like the infix operator, using `Ratio.new(numerator, denomerator)`)

Notice that Rationals are automaically simplified, and coerced to integers whenever possible.

      iex> use Ratio
      nil
      iex> 1 <|> 2
      1 <|> 2
      iex> 2 <|> 1
      2
      iex> 100 <|> 300
      1 <|> 3
      iex> 1.5 <|> 4
      3 <|> 8

The normal arithmetic-operators are overloaded by Ratio to allow arithmetic with Rationals (as well as normal ints and floats). (If you do not like to overload the infix operators, there are also longhand variants available.)

      iex> 2 + (2 <|> 3)
      5 <|> 5
      iex> 2.3 + 0.3
      13 <|> 5
      iex> (2 <|> 3) - (1 <|> 5)
      7 <|> 15
      iex> (1 <|> 3) / 2
      1 <|> 6
      iex> (2 <|> 3) / (8 <|> 5)
      5 <|> 12

Floats are converted to Rational numbers before performing arithmetic. This allows for more precise results.

      iex> Kernel.-(2.3, 0.3)
      1.9999999999999998
      iex> Kernel.-(2.3, 0.1)
      2.1999999999999997
      iex> use Ratio
      nil
      iex> 2.3 - 0.3
      2
      iex> 2.3 - 0.1
      11 <|> 5

*(Of course, when possible, working with integers from the get-go is always more precise than converting floats)*




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add rational to your list of dependencies in `mix.exs`:

        def deps do
          [
            {:ratio, "~> 0.6.0"}
          ]
        end

  2. use Ratio wherever you want to use Rational numbers

        use Ratio

  or

        # Does not override +, -, *, /
        use Ratio, without_inline_math: true 

  or

        # Does not override +, -, *, /, abs, div
        use Ratio, without_overridden_math: true 



## Changelog
- 0.6.0 First public release
- 0.0.1 First features


## Difference with the 'rational' library

Observant readers might notice that there also is a '[rational](https://hex.pm/packages/rational)' library in Hex.pm. The design idea between that library vs. this one is a bit different: `Ratio` hides the internal data representation as much as possible, and numbers are therefore created using `Rational.<|>/2` or `Ratio.new/2`. This has as mayor advantage that the internal representation is always correct and simplified.

The Ratio library also (optionally) overrides the built-in math operations `+, -, *, /, div, abs` so they work with combinations of integers, floats and rationals.
