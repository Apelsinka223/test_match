defmodule TestMatch do
  @moduledoc """
  Matching function for ExUnit tests
  """

  @doc """
  Checks if given attributes matches

  Returns `true` or raises ExUnit.AssertionError

  ## Example

  The assertion

      assert test_match %{a: 1}, %{a: 1, b: 2}

  will match.

      assert test_match %{a: 1, b: 2}, %{a: 1}

  will fail with the message:

      match (test_match) failed
      left: %{a: 1, b: 2},
      right: %{a: 1}

  """

  @spec test_match(any(), any(), list()) :: boolean()
  def test_match(pattern, %{__struct__: _} = tested, options) do
    test_match(pattern, Map.from_struct(tested), options)
  end

  def test_match(%{__struct__: _} = pattern, tested, options) do
    test_match(Map.from_struct(pattern), tested, options)
  end

  def test_match(pattern, tested, options) when is_tuple(tested) and is_tuple(pattern) do
    test_match(Tuple.to_list(pattern), Tuple.to_list(tested), options)
  end

  def test_match(pattern, tested, options) when is_list(tested) and is_list(pattern) do
    pattern
    |> Enum.zip(tested)
    |> Enum.all?(fn {pattern_item, tested_item} -> test_match(pattern_item, tested_item, options) end)
  end

  def test_match(pattern, tested, options) when is_map(tested) and is_map(pattern) do
    exactly = options[:exactly]
    Enum.all?(pattern, fn
      {_key, :_} -> true

      {key, value} when is_map(value) or is_list(value) ->
        test_match(value, tested[key], options)

      {key, value} when exactly === true ->
        value === tested[key]

      {key, value} ->
        value == tested[key]
    end)
  end

  def test_match(a, a, [exactly: true]), do: true
  def test_match(a, b, [exactly: true]) when a !== b, do: false
  def test_match(a, b, [exactly: false]), do: a == b

  defmacro __using__([]) do
    quote do
      defmacro assert_match(left, right, opts \\ [exactly: true]) do
        test_match = {{:., [], [{:__aliases__, [alias: false], [:TestMatch]}, :test_match]}, [], [left, right, opts]}
        quote do
          right = unquote(right)
          left = unquote(left)

          ExUnit.Assertions.assert unquote(test_match),
               right: right,
               left: left,
               message: "match (assert_match) failed"
        end
      end
      
      defmacro refute_match(left, right, opts \\ [exactly: true]) do
        test_match = {{:., [], [{:__aliases__, [alias: false], [:TestMatch]}, :test_match]}, [], [left, right, opts]}
        quote do
          right = unquote(right)
          left = unquote(left)

          ExUnit.Assertions.refute unquote(test_match),
               message: "match (refute_match) succeeded, but should have failed"
        end
      end
    end
  end
end
