defmodule RecursiveMatch do
  alias IO.ANSI
  @moduledoc """
  Recursive matching
  """

  @doc """
  Matches given value with pattern

  Returns `true` or `false`

  ## Parameters

  - pattern: Expected pattern (use `:_` instead of `_`)

  - tested: Tested value

  - options: Options

        * `strict`, when `true` compare using `===`, when `false` compare using `==`, default `true`

        * `ignore_order`,  when `true` - ignore order of items in lists, default `false`

  ## Example

      iex> import RecursiveMatch
      RecursiveMatch
      iex> match_r %{a: 1}, %{a: 1, b: 2}
      true
      iex> match_r %{a: 1, b: 2}, %{a: 1}
      false
  """

  defmacro __using__([]) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @spec match_r(term, term, list | nil) :: boolean
  def match_r(pattern, tested, options \\ [strict: true])

  def match_r(pattern, %{__struct__: _} = tested, options) do
    match_r(pattern, Map.from_struct(tested), options)
  end

  def match_r(:_, _, options), do: true

  def match_r(%{__struct__: _} = pattern, tested, options) do
    match_r(Map.from_struct(pattern), tested, options)
  end

  def match_r(pattern, tested, options) when is_tuple(tested) and is_tuple(pattern) do
    match_r(Tuple.to_list(pattern), Tuple.to_list(tested), options)
  end

  def match_r(pattern, tested, options) when is_list(tested) and is_list(pattern) do
    if Enum.count(pattern) == Enum.count(tested) do
      if options[:ignore_order] == true do
        match_lists_ignore_order(pattern, tested, options)
      else
        pattern
        |> Enum.zip(tested)
        |> Enum.all?(fn {pattern_item, tested_item} ->
             match_r(pattern_item, tested_item, options)
           end)
      end
    else
      false
    end
  end

  def match_r(pattern, tested, options) when is_map(tested) and is_map(pattern) do
    strict = options[:strict]
    Enum.all?(pattern, fn
      {_key, :_} -> true

      {key, value} ->
        match_r(value, tested[key], options)
    end)
  end

  def match_r(a, a, _), do: true
  def match_r(a, b, options) do
    case options[:strict] do
      true -> a === b
      nil -> a === b
      false -> a == b
    end
  end

  defp match_lists_ignore_order([], [], _), do: true

  defp match_lists_ignore_order([pattern | pattern_tail], tested, options) do
    case Enum.find_index(tested, fn t -> match_r(pattern, t, options) end) do
      nil ->
        false

      index ->
        tested_rest = List.delete_at(tested, index)
        match_lists_ignore_order(pattern_tail, tested_rest, options)
    end
  end

  @doc """
  Matches given value with pattern

  Returns `true` or raises `ExUnit.AssertionError`

  ## Parameters

  - pattern: Expected pattern (use `:_` instead of `_`)

  - tested: Tested value

  - options: Options

          * strict: when `true` compare using `===`, when `false` compare using `==`, default `true`

          * `ignore_order`,  when `true` - ignore order of items in lists, default `false`

          * message: Custom message on fail

  ## Example

  The assertion

      assert_match %{a: 1}, %{a: 1, b: 2}

  will match,

      assert_match %{a: 1, b: 2}, %{a: 1}

  will fail with the message:

      match (assert_match) failed
      left:  %{a: 1, b: 2},
      right: %{a: 1}
  """

  @spec assert_match(term, term, list | nil) :: boolean
  defmacro assert_match(left, right, options \\ [strict: true]) do
    match_r = {:match_r, [], [left, right, options]}
    message = options[:message] || "match (assert_match) failed"
    quote do
      right = unquote(right)
      left = unquote(left)
      message = unquote(message)

      ExUnit.Assertions.assert unquote(match_r),
                               right: right,
                               left: left,
                               message: message
    end
  end

  @doc """
  Matches given value with pattern

  Returns `true` or raises `ExUnit.AssertionError`

  ## Parameters

  - pattern: Expected pattern (use `:_` instead of `_`)

  - tested: Tested value

  - options: Options

          * strict: when `true` compare using `===`, when `false` compare using `==`, default `true`

          * `ignore_order`,  when `true` - ignore order of items in lists, default `false`

          * message: Custom message on fail


  ## Example

  The assertion

      assert_match %{a: 1}, %{a: 1, b: 2}

  will match,

      assert_match %{a: 1, b: 2}, %{a: 1}

  will fail with the message:

      match (refute_match) succeeded, but should have failed
  """
  @spec refute_match(term, term, list | nil) :: boolean
  defmacro refute_match(left, right, options \\ [strict: true]) do
    match_r = {:match_r, [], [left, right, options]}
    message = options[:message] || "match (refute_match) succeeded, but should have failed"
    quote do
      message = unquote(message)

      ExUnit.Assertions.refute unquote(match_r), message: message
    end
  end

  def formatter(left, right, options) do

  end


  def format_message({left, right}, left, right) do

  end

  def format_message(difference) when is_list(difference) do
    difference
    |> Enum.map(fn
         {:eq, value} -> to_string(value)
         {:ins, value} -> ANSI.green() <> to_string(value) <> ANSI.reset()
         {:del, value} -> ANSI.red() <> to_string(value) <> ANSI.reset()
       end)
    |> Enum.join()
  end


  @spec diff(term, term, list | nil) :: boolean
  def diff(pattern, tested, options \\ [strict: true])

  def diff(:_, tested, options) do
    {[eq: "_"], [eq: tested]}
  end

  def diff(pattern, tested, options) when is_binary(pattern) and is_binary(tested) do
    {
      Keyword.delete(String.myers_difference(pattern, tested), :ins),
      Keyword.delete(String.myers_difference(tested, pattern), :del)
    }
  end

  def diff(pattern, tested, options) when is_list(pattern) and is_list(tested) do
    if options[:ignore_order] == true do
      diff_lists_ignore_order(pattern, tested, options)
    else
      diff =
        pattern
        |> Enum.zip(tested)
        |> Enum.flat_map(fn
            {{key, pattern_item}, {key, tested_item}} ->
              [{key, diff(pattern_item, tested_item, options)}]

            {{key, pattern_item}, {another_key, tested_item}} ->
              [{[del: key], {[del: pattern_item]}}, {[ins: another_key], {[ins: tested_item]}}]

            {pattern_item, tested_item} ->
              [diff(pattern_item, tested_item, options)]
           end)
    end
  end

  def diff(pattern, tested, options) when is_map(tested) and is_map(pattern) do
    strict = options[:strict]

    pattern
    |> Enum.map(fn
        {key, :_} -> {key, {[eq: "_"], [eq: tested[key]]}}

        {key, value} ->
          {key, diff(value, tested[key], options)}
      end)
    |>  Enum.into(%{})
  end

  def diff(pattern, tested, options) do
    if match_r(pattern, tested, options) do
      {[del: pattern], [ins: tested]}
    else
      {[eq: pattern], [eq: tested]}
    end
  end


  defp diff_lists_ignore_order([], [], _), do: {[eq: []], [eq: []]}

  defp diff_lists_ignore_order([pattern | pattern_tail], tested, options) do
    case Enum.find_index(tested, fn t -> match_r(pattern, t, options) end) do
      nil ->
        false

      index ->
        tested_rest = List.delete_at(tested, index)
        diff_lists_ignore_order(pattern_tail, tested_rest, options)
    end
  end
end
