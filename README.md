# RecursiveMatch

Module for matching

### What difference between `Kernel.match?/2` and `RecursiveMatch.match_r/3`?
When you use `Kernel.match?/2`
* can't invoke functions in pattern
* can't match not strict equality (only `===`, no `==`)

`RecursiveMatch.match_r/3` allows you invoke functions in patterns, match not strictly (with option `strict: false`)

### What is for `assert_match/3` and `refute_match/3`?
Is is same as `assert RecursiveMatch.match_r`, but with detailed fail message. ExUnit has no special message for `match_r/3` and even special message for `match?/2` is not detailed enough, it has no diff in fail message.

`assert_match/3` provide diff in test fail message


<img src="/images/screenshot.png?raw=true" width="500" height="155">

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `test_match` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:test_match, "~> 1.1.0"}
  ]
end
```

## Usage
```elixir
defmodule YourModule do
  import RecursiveMatch

  def some_function do
    ...
    match_r a, b
    ...
  end
end

```


```elixir
defmodule YourModuleTest do
  use ExUnit.Case
  use RecursiveMatch

  test "some test" do
    ...
    assert_match a, b
    refute_match a, c
    ...
  end
end

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/test_match](https://hexdocs.pm/test_match).
