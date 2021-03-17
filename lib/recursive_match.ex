defmodule RecursiveMatch do
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
  @spec match_r(term, term, list | nil) :: boolean
  def match_r(pattern, tested, options \\ [strict: true])

  def match_r(pattern, %{__struct__: _} = tested, options) do
    match_r(pattern, Map.from_struct(tested), options)
  end

  def match_r(:_, _, _), do: true

  def match_r(%{__struct__: _} = pattern, tested, options) do
    match_r(Map.from_struct(pattern), tested, options)
  end

  def match_r(pattern, tested, options) when is_tuple(tested) and is_tuple(pattern) do
    list_pattern = Tuple.to_list(pattern)
    list_tested = Tuple.to_list(tested)

    if Enum.count(list_pattern) == Enum.count(list_tested) do
      list_pattern
      |> Enum.zip(list_tested)
      |> Enum.all?(fn {pattern_item, tested_item} ->
        match_r(pattern_item, tested_item, options)
      end)
    else
      false
    end
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

      {key, value} when is_map(value) or is_list(value) ->
        match_r(value, tested[key], options)

      {key, value} when strict === true ->
        Map.has_key?(tested, key) and value === Map.get(tested, key)

      {key, value} ->
        Map.has_key?(tested, key) and value == Map.get(tested, key)
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

  def prepare_right_for_diff(pattern, tested, options)
      when is_struct(tested) and not is_struct(pattern),
    do: prepare_right_for_diff(pattern, Map.from_struct(tested), options)

  def prepare_right_for_diff(%{__struct__: struct} = pattern, tested, options)
      when is_struct(tested) and is_struct(pattern) do
    pattern
    |> Map.from_struct()
    |> Enum.map(fn
      {_key, :_} ->
        tested

      {key, value} ->
        if Map.has_key?(pattern, key) do
          {key, prepare_right_for_diff(Map.get(pattern, key), value, options)}
        else
          nil
        end
    end)
    |> Enum.filter(& elem(&1, 1))
    |> (& struct(struct, &1)).()
  end

  def prepare_right_for_diff(pattern, tested, options)
       when is_list(tested) and is_list(pattern) do
    if options[:ignore_order] === true do
      tested
      |> Enum.sort_by(&Enum.find_index(pattern, fn v -> v == &1 end), &<=/2)
      |> zip_with_rest(pattern)
      |> Enum.map(fn {tested, pattern} ->
        prepare_right_for_diff(pattern, tested, options)
      end)
      |> Enum.filter(& &1 != :zip_nil)
    else
      tested
      |> zip_with_rest(pattern)
      |> Enum.map(fn {tested, pattern} ->
        prepare_right_for_diff(pattern, tested, options)
      end)
      |> Enum.filter(& &1 != :zip_nil)
    end
  end

  def prepare_right_for_diff(pattern, tested, options)
       when is_map(tested) and is_map(pattern) do
    tested
    |> filter_tested(pattern)
    |> Enum.map(fn
      {_key, :_} ->
        :_

      {key, value} ->
        if Map.has_key?(pattern, key) do
          {key, prepare_right_for_diff(Map.get(pattern, key), value, options)}
        else
          nil
        end
    end)
    |> Enum.filter(& elem(&1, 1))
    |> Map.new()
  end

  def prepare_right_for_diff(pattern, tested, options)
      when is_tuple(pattern) and is_tuple(tested) do

    list_pattern = Tuple.to_list(pattern)
    list_tested = Tuple.to_list(tested)

    list_tested
    |> zip_with_rest(list_pattern)
    |> Enum.map(fn {tested, pattern} ->
      prepare_right_for_diff(pattern, tested, options)
    end)
    |> Enum.filter(& &1 != :zip_nil)
    |> List.to_tuple()
  end

  def prepare_right_for_diff(_pattern, tested, _options), do: tested

  defp filter_tested(tested, pattern) do
    if list_intersection(Map.keys(tested), Map.keys(pattern)) == [] do
      tested
    else
      Map.take(tested, Map.keys(pattern))
    end
  end

  defp list_intersection(a, b), do: a -- (a -- b)

  def prepare_left_for_diff(pattern, tested, options)
      when is_struct(pattern) and not is_struct(tested),
    do: prepare_left_for_diff(Map.from_struct(pattern), tested, options)

  def prepare_left_for_diff(%{__struct__: struct} = pattern, tested, options)
      when is_struct(tested) and is_struct(pattern) do
    pattern
    |> Map.from_struct
    |> Enum.map(fn
      {_key, :_} ->
        :_

      {key, value} ->
        {key, prepare_left_for_diff(value, Map.get(tested, key), options)}
    end)
    |> Map.new()
    |> (& struct(struct, &1)).()
  end

  def prepare_left_for_diff(pattern, tested, options)
       when is_list(tested) and is_list(pattern) do
    pattern
    |> zip_with_rest(tested)
    |> Enum.map(fn {pattern, tested} ->
      prepare_left_for_diff(pattern, tested, options)
    end)
   |> Enum.filter(& &1 != :zip_nil)
  end

  def prepare_left_for_diff(pattern, tested, options)
       when is_map(tested) and is_map(pattern) do
    pattern
    |> Enum.map(fn
      {_key, :_} ->
        :_

      {key, value} ->
        {key, prepare_left_for_diff(value, Map.get(tested, key), options)}
    end)
    |> Map.new()
  end

  def prepare_left_for_diff(pattern, _tested, _options), do: pattern

  defp zip_with_rest(a, b) do
    if length(a) > length(b) do
      Enum.reduce(a, {[], b}, fn
        a_i, {acc, [b_i | b_rest]} ->
          {[{a_i, b_i} | acc], b_rest}

        a_i, {acc, []} ->
          {[{a_i, :zip_nil} | acc], []}
      end)
    else
      Enum.reduce(b, {[], a}, fn
        b_i, {acc, [a_i | a_rest]} ->
          {[{a_i, b_i} | acc], a_rest}

        b_i, {acc, []} ->
          {[{:zip_nil, b_i} | acc], []}
      end)
    end
    |> elem(0)
    |> Enum.reverse()
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
    message = options[:message] || "match (assert_match) failed"
    quote do

      right = unquote(right)
      left = unquote(left)
      message = unquote(message)
      options = unquote(options)

      prepared_right = prepare_right_for_diff(left, right, options)
      prepared_left = prepare_left_for_diff(left, right, options)

      ExUnit.Assertions.assert match_r(left, right, options),
                               right: prepared_right,
                               left: prepared_left,
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
    message = options[:message] || "match (refute_match) succeeded, but should have failed"
    quote do
      right = unquote(right)
      left = unquote(left)
      message = unquote(message)
      options = unquote(options)

      ExUnit.Assertions.refute match_r(left, right, options), message: message
    end
  end

  defmacro __using__([]) do
    quote do
      import unquote(__MODULE__)
    end
  end
end
