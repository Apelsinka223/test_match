defmodule TestMatchTest do
  use ExUnit.Case
  doctest TestMatch
  use TestMatch

  defp fun_a(), do: 1
  defp fun_b(), do: 2
  defp fun_c(), do: 1

  describe "assert_match?/2" do
    test "values" do
      assert_match 1, 1
      assert_raise ExUnit.AssertionError, fn -> assert_match 1, 2 end
    end
  
    test "variables" do
      a = 1
      b = 2
      c = 1
      assert_match a, c
      assert_raise ExUnit.AssertionError, fn -> assert_match a, b end
    end

    test "functions" do
      assert_match fun_a(), fun_c()
      assert_raise ExUnit.AssertionError, fn -> assert_match fun_a(), fun_b() end
    end
  
    test "maps" do
      a = %{a: 1, c: %{a: 1}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}
  
      assert_match %{c: %{a: 1}}, %{b: 1, c: %{a: 1}}
      assert_raise ExUnit.AssertionError, fn -> assert_match b, a end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c end
      assert_match a.a, b.a
    end
  
    test "list of maps" do
      a = [%{a: 1, c: %{a: 1}}]
      b = [%{a: 1, b: 2, c: %{a: 1, b: 2}}]
      c = [%{b: 2}]
  
      assert_match a, b
      assert_raise ExUnit.AssertionError, fn -> assert_match b, a end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c end
    end
  end  
  
  describe "assert_match?/3" do
    test "exactly false" do
      assert_match 1, 1.0, exactly: false
      assert_match 1.0, 1, exactly: false

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert_match a, b, exactly: false
      assert_raise ExUnit.AssertionError, fn -> assert_match b, a, exactly: false end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c, exactly: false end
      assert_raise ExUnit.AssertionError, fn -> assert_match c, a, exactly: false end

      d = 1.0
      e = 1
      f = 2

      assert_match d, e, exactly: false
      assert_match e, d, exactly: false
      assert_raise ExUnit.AssertionError, fn -> assert_match d, f, exactly: false end
    end

    test "exactly true" do
      assert_raise ExUnit.AssertionError, fn -> assert_match 1, 1.0, exactly: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match 1.0, 1, exactly: true end

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert_raise ExUnit.AssertionError, fn -> assert_match a, b, exactly: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match b, a, exactly: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c, exactly: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match c, a, exactly: true end

      d = 1.0
      e = 1
      f = 2

      assert_raise ExUnit.AssertionError, fn -> assert_match d, e, exactly: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match e, d, exactly: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match d, f, exactly: true end
    end
  end
  
  describe "refute_match?/2" do
    test "values" do
      refute_match 1, 2
      assert_raise ExUnit.AssertionError, fn -> refute_match 1, 1 end
    end
  
    test "variables" do
      a = 1
      b = 1
      c = 2
      refute_match a, c
      assert_raise ExUnit.AssertionError, fn -> refute_match a, b end
    end

    test "functions" do
      refute_match fun_a(), fun_b()
      assert_raise ExUnit.AssertionError, fn -> refute_match fun_a(), fun_c() end
    end
  
    test "maps" do
      a = %{a: 1, c: %{a: 1}}
      b = %{b: 2}
      c = %{a: 1}
  
      refute_match %{b: 1, c: %{a: 1}}, %{c: %{a: 1}}
      refute_match b, a
      refute_match a, c
      assert_raise ExUnit.AssertionError, fn -> refute_match c, a end
    end
  
    test "list of maps" do
      a = [%{a: 1, c: %{a: 1}}]
      b = [%{b: 2}]
      c = [%{a: 1}]
  
      refute_match a, b
      refute_match b, a
      refute_match a, c
      assert_raise ExUnit.AssertionError, fn -> refute_match c, a end
    end
  end  
  
  describe "refute_match?/3" do
    test "exactly false" do
      assert_raise ExUnit.AssertionError, fn -> refute_match 1, 1.0, exactly: false end
      assert_raise ExUnit.AssertionError, fn -> refute_match 1.0, 1, exactly: false end

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{b: 2}
      c = %{a: 1.0}

      refute_match a, b, exactly: false
      refute_match b, a, exactly: false
      refute_match a, c, exactly: false
      assert_raise ExUnit.AssertionError, fn -> refute_match c, a, exactly: false end

      d = 1.0
      e = 1
      f = 1.0

      assert_raise ExUnit.AssertionError, fn -> refute_match d, e, exactly: false end
      assert_raise ExUnit.AssertionError, fn -> refute_match e, d, exactly: false end
      assert_raise ExUnit.AssertionError, fn -> refute_match d, f, exactly: false end
    end

    test "exactly true" do
      refute_match 1, 1.0, exactly: true
      refute_match 1.0, 1, exactly: true

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{a: 1.0}

      refute_match a, b, exactly: true
      refute_match b, a, exactly: true
      refute_match a, c, exactly: true
      assert_raise ExUnit.AssertionError, fn -> refute_match c, a, exactly: true end

      d = 1.0
      e = 1
      f = 1.0

      refute_match d, e, exactly: true
      refute_match e, d, exactly: true
      assert_raise ExUnit.AssertionError, fn -> refute_match d, f, exactly: true end
    end
  end
end
