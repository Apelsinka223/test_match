defmodule TestMatch do
  @moduledoc """
  Matching function for ExUnit tests
  """

  @doc """
  Checks if given attributes matches

  Returns `true` or raises ExUnit.AssertionError

  ## Example

  The assertion

      assert test_match? %{a: 1}, %{a: 1, b: 2}

  will match.

      assert test_match? %{a: 1, b: 2}, %{a: 1}

  will fail with the message:

      match (test_match?) failed
      left: %{a: 1, b: 2},
      right: %{a: 1}

  """

  @spec test_match?(any(), any(), list()) :: boolean()
  def test_match?(small_map, big_map, options \\ [exactly: true])

  def test_match?(small_map, %{__struct__: _} = big_map, options) do
    test_match?(small_map, Map.from_struct(big_map), options)
  end

  def test_match?(%{__struct__: _} = small_map, big_map, options) do
    test_match?(Map.from_struct(small_map), big_map, options)
  end

  def test_match?(small_map, big_map, options) when is_list(big_map) and is_list(small_map) do
    small_map
    |> Enum.zip(big_map)
    |> Enum.all?(fn {small, big} -> test_match?(small, big, options) end)
    |> case do
         false ->
           raise ExUnit.AssertionError,
                 left: small_map,
                 right: big_map,
                 message: "match (test_match?) failed"
         true -> true
       end
  end

  def test_match?(small_map, big_map, options) when is_map(big_map) do
    small_map
    |> Enum.all?(
         fn
           {_key, :_} -> true
           {key, value} when is_map(value) or is_list(value) ->
             test_match?(value, big_map[key], options)
           {key, value} = item ->
             if options[:exactly] do
               Enum.member?(big_map, item)
             else
               value == big_map[key]
             end
         end
       )
    |> case do
         false ->
           raise ExUnit.AssertionError,
                 left: small_map,
                 right: big_map,
                 message: "match (test_match?) failed"
         true -> true
       end
  end

  def test_match?(a, a, _), do: true

  def test_match?(a, b, _),
      do: raise ExUnit.AssertionError,
          left: a,
          right: b,
          message: "match (test_match?) failed"
end
