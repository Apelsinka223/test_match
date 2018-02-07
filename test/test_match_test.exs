defmodule TestMatchTest do
  use ExUnit.Case
  doctest TestMatch
  import TestMatch

  test "values" do
    assert test_match? 1, 1
    assert_raise ExUnit.AssertionError, fn -> test_match? 1, 2 end
  end

  test "variables" do
    a = 1
    b = 2
    c = 1
    assert test_match? a, c
    assert_raise ExUnit.AssertionError, fn -> test_match? a, b end
  end

  test "functions" do
    assert test_match? fun_a(), fun_c()
    assert_raise ExUnit.AssertionError, fn -> test_match? fun_a(), fun_b() end
  end

  defp fun_a(), do: 1
  defp fun_b(), do: 2
  defp fun_c(), do: 1

  test "maps" do
    a = %{a: 1, c: %{a: 1}}
    b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
    c = %{b: 2}

    assert test_match? a, b
    assert_raise ExUnit.AssertionError, fn -> test_match? b, a end
    assert_raise ExUnit.AssertionError, fn -> test_match? a, c end
    assert_raise ExUnit.AssertionError, fn -> test_match? a, c end
    assert test_match? a.a, b.a
  end

  test "list of maps" do
    a = [%{a: 1, c: %{a: 1}}]
    b = [%{a: 1, b: 2, c: %{a: 1, b: 2}}]
    c = [%{b: 2}]

    assert test_match? a, b
    assert_raise ExUnit.AssertionError, fn -> test_match? b, a end
    assert_raise ExUnit.AssertionError, fn -> test_match? a, c end
    assert_raise ExUnit.AssertionError, fn -> test_match? a, c end
  end
end
