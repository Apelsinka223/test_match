defmodule RecursiveMatch do
  @moduledoc """
  Recursive matching
  """

  defmacro __using__([]) do
    quote do
      @doc """
      Recursive matches given value with pattern

      Returns `true` or `false`

      ## Parameters

      - pattern: Expected pattern

      - tested: Tested value

      - opts: * exactly, when `true` compare with `===`, when `false` compare with `==`

      ## Example

        iex> match_r %{a: 1}, %{a: 1, b: 2}
        true

        iex> match_r %{a: 1, b: 2}, %{a: 1}
        false
      """
      @spec match_r(any(), any(), list() | nil) :: boolean()
      def match_r(pattern, tested, options \\ [exactly: true])

      def match_r(pattern, %{__struct__: _} = tested, options) do
        match_r(pattern, Map.from_struct(tested), options)
      end

      def match_r(%{__struct__: _} = pattern, tested, options) do
        match_r(Map.from_struct(pattern), tested, options)
      end

      def match_r(pattern, tested, options) when is_tuple(tested) and is_tuple(pattern) do
        match_r(Tuple.to_list(pattern), Tuple.to_list(tested), options)
      end

      def match_r(pattern, tested, options) when is_list(tested) and is_list(pattern) do
        if Enum.count(pattern) == Enum.count(tested) do
          pattern
          |> Enum.zip(tested)
          |> Enum.all?(fn {pattern_item, tested_item} ->
            match_r(pattern_item, tested_item, options)
          end)
        else
          false
        end
      end

      def match_r(pattern, tested, options) when is_map(tested) and is_map(pattern) do
        exactly = options[:exactly]
        Enum.all?(pattern, fn
          {_key, :_} -> true

          {key, value} when is_map(value) or is_list(value) ->
            match_r(value, tested[key], options)

          {key, value} when exactly === true ->
            value === tested[key]

          {key, value} ->
            value == tested[key]
        end)
      end

      def match_r(a, a, opts), do: true
      def match_r(a, b, opts) do
        case opts[:exactly] do
          true -> a === b
          nil -> a === b
          false -> a == b
        end
     end

      @doc """
      Recursive matches given value with pattern

      Returns `true` or raises `ExUnit.AssertionError`

      ## Parameters

      - pattern: Expected pattern

      - tested: Tested value

      - opts: * exactly: when `true` compare with `===`, when `false` compare with `==`

              * message: Custom message on faile

      ## Example

      The assertion

          assert_match %{a: 1}, %{a: 1, b: 2}

      will match_r.

          assert_match %{a: 1, b: 2}, %{a: 1}

      will fail with the message:

          match_(assert_match) failed
          left: %{a: 1, b: 2},
          right: %{a: 1}
      """

      @spec assert_match(any(), any(), list() | nil) :: boolean()
      defmacro assert_match(left, right, opts \\ [exactly: true]) do
        match_r = {:match_r, [], [left, right, opts]}
        message = opts[:message] || "match (assert_match) failed"
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
      Recursive matches given value with pattern

      Returns `true` or raises `ExUnit.AssertionError`

      ## Parameters

      - pattern: Expected pattern

      - tested: Tested value

      - opts: * exactly: when `true` compare with `===`, when `false` compare with `==`

              * message: Custom message on faile


      ## Example

      The assertion

          assert_match %{a: 1}, %{a: 1, b: 2}

      will match,

          assert_match %{a: 1, b: 2}, %{a: 1}

      will fail with the message:

          match (refute_match) succeeded, but should have failed
      """

      @spec refute_match(any(), any(), list() | nil) :: boolean()
      defmacro refute_match(left, right, opts \\ [exactly: true]) do
        match_r = {:match_r, [], [left, right, opts]}
        message = opts[:message] || "match (refute_match) succeeded, but should have failed"
        quote do
          right = unquote(right)
          left = unquote(left)
          message = unquote(message)

          ExUnit.Assertions.refute unquote(match_r),
               message: message
        end
      end
    end
  end
end
