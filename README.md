
[![Hex.pm](https://img.shields.io/hexpm/v/test_match.svg)](https://hex.pm/packages/test_match)
[![Build Status](https://travis-ci.org/Apelsinka223/test_match.svg?branch=master)](https://travis-ci.org/Apelsinka223/test_match)
[![Coverage Status](https://coveralls.io/repos/github/Apelsinka223/test_match/badge.svg?branch=master)](https://coveralls.io/github/Apelsinka223/test_match?branch=master)
[![Inline docs](http://inch-ci.org/github/Apelsinka223/test_match.svg?branch=master)](http://inch-ci.org/github/Apelsinka223/test_match)

# RecursiveMatch

Module for matching

### What difference between `Kernel.match?/2` and `RecursiveMatch.match_r/3`?
When you use `Kernel.match?/2`
* can't use functions as pattern
* can't match not strict equality (only `===`, no `==`)

`RecursiveMatch.match_r/3` allows you:
* use functions as patterns
* match not strictly (with option `strict: false`)
* ignore order of lists item (with option `ignore_order: true`)

### What is for `assert_match/3` and `refute_match/3`?
It is same as `assert RecursiveMatch.match_r`, but with detailed fail message.   
ExUnit has no special message for `match_r/3` and even no special message for `match?/2` is not detailed enough, it has no diff in fail message.

`assert_match/3` provides diff in test fail message


<img src="/images/screenshot.png?raw=true" width="500" height="155">

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_match` to your list of dependencies in `mix.exs`:

**Requires `elixir ~> 1.5`**

```elixir
def deps do
  [
    {:test_match, "~> 1.2.0"}
  ]
end
```

## Usage
```elixir
defmodule YourModule do
  import RecursiveMatch

  def function1 do
    ...
  end
  
  def function2 do
    ...
    match_r 1, 2 
    match_r a, b
    match_r :_, b
    match_r function1(), 1
    match_r [1, 2], [2, 1], ignore_order: true # true
    match_r 1, 1.0, strict: true               # false
    ...
  end
end

```

```elixir
defmodule YourModuleTest do
  use ExUnit.Case
  import RecursiveMatch

  test "some test" do
    ...
    assert_match 1, 2 # false
    assert_match :_, b
    assert_match a, b
    assert_match [1, 2], [2, 1], ignore_order: true
    refute_match 1, 1.0
    assert_match 1, 1.0, strict: false          
    refute_match a, c
    assert_match YourModule.function1(), 1
    ...
  end
end

```
 ## Options
   * `strict`: when `true` compare using `===`, when `false` compare using `==`, default `true`
   * `ignore_order`,  when `true` - ignore order of items in lists, default `false`
   * `message`: Custom message on fail

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/test_match](https://hexdocs.pm/test_match).

