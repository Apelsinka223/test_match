defmodule RecursiveMatchTest do
  use ExUnit.Case
  doctest RecursiveMatch
  import RecursiveMatch

  defp fun_a(), do: 1
  defp fun_b(), do: 2
  defp fun_c(), do: 1

  defmodule TestStruct do
    defstruct [:field1, :field2]
  end

  describe "match_r/3" do
    test "values" do
      assert match_r 1, 1
      refute match_r 1, 2
    end

    test "variables" do
      a = 1
      b = 2
      c = 1

      assert match_r a, c
      refute match_r a, b
    end

    test "functions" do
      assert match_r fun_a(), fun_c()
      refute match_r fun_a(), fun_b()
    end

    test "maps" do
      a = %{a: 1, c: %{a: 1}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert match_r a, b
      refute match_r b, a
      refute match_r a, c
      refute match_r c, a
      assert match_r a.a, b.a
    end

    test "structs" do
      a = %TestStruct{field1: 1, field2: %{a: 1}}
      b = %TestStruct{field1: 1, field2: %{a: 1, b: 2}}
      c = %TestStruct{field1: 1}

      assert match_r a, b
      refute match_r b, a
      assert match_r %{field1: 1}, a
      refute match_r c, a
      refute match_r a, c
      assert match_r a.field1, b.field1
    end

    test "tuples" do
      a = {1, 2}
      b = {1, 2}
      c = {2, 1}

      assert match_r a, b
      assert match_r b, a
      refute match_r a, c
      refute match_r c, a
    end

    test "lists" do
      a = [1, 2]
      b = [1, 2]
      c = [2, 1]
      d = [4]
      e = [1]
      f = [%{a: 1, b: [2, 1, 3]}, %{a: 2, b: [2, 1]}]
      g = [%{b: [1, 2]}, %{b: [1, 2, 3]}]

      assert match_r a, b
      assert match_r b, a
      refute match_r a, c
      refute match_r c, a
      refute match_r d, a
      refute match_r a, e
      refute match_r e, a
      assert match_r a, c, ignore_order: true
      assert match_r c, a, ignore_order: true
      refute match_r a, d, ignore_order: true
      refute match_r d, a, ignore_order: true
      refute match_r a, e, ignore_order: true
      refute match_r e, a, ignore_order: true
      assert match_r g, f, ignore_order: true
      refute match_r g, f
      refute match_r f, g, ignore_order: true
    end

    test "keyword lists" do
      a = [a: 1]
      b = [a: 1]
      c = [b: 2, a: 1]
      d = [d: 1]
      e = [a: 1, b: 2]

      assert match_r a, b
      assert match_r b, a
      refute match_r a, c
      refute match_r c, a
      refute match_r d, a
      refute match_r a, e
      refute match_r e, a
      assert match_r c, e, ignore_order: true
      assert match_r e, c, ignore_order: true
      refute match_r a, c, ignore_order: true
      refute match_r c, a, ignore_order: true
    end

    test "strict false" do
      assert match_r 1, 1.0, strict: false
      assert match_r 1.0, 1, strict: false

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert match_r a, b, strict: false
      refute match_r b, a, strict: false
      refute match_r a, c, strict: false
      refute match_r c, a, strict: false

      d = 1.0
      e = 1
      f = 2

      assert match_r d, e, strict: false
      assert match_r e, d, strict: false
      refute match_r d, f, strict: false
    end

    test "strict true" do
      assert match_r 1.0, 1.0, strict: true
      assert match_r 1, 1, strict: true
      refute match_r 1, 1.0, strict: true
      refute match_r 1.0, 1, strict: true

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      refute match_r a, b, strict: true
      refute match_r b, a, strict: true
      refute match_r a, c, strict: true
      refute match_r c, a, strict: true

      d = 1.0
      e = 1
      f = 2

      refute match_r d, e, strict: true
      refute match_r e, d, strict: true
      refute match_r d, f, strict: true
    end
  end

  describe "assert_match?/3" do
    test "values" do
      assert_match 1, 1

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 2
                   """,
                   fn -> assert_match 1, 2 end
    end

    test "variables" do
      a = 1
      b = 2
      c = 1

      assert_match a, c

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 2
                   """,
                   fn -> assert_match a, b end
    end

    test "functions" do
      assert_match fun_a(), fun_c()

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 2
                   """,
                   fn -> assert_match fun_a(), fun_b() end
    end

    test "strict false" do
      assert_match 1, 1.0, strict: false
      assert_match 1.0, 1, strict: false

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert_match a, b, exactly: false

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1, b: 2, c: %{a: 1, b: 2}}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """,
                   fn -> assert_match b, a, strict: false end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1.0, c: %{a: 1.0}}
                   right: %{b: 2}
                   """,
                   fn -> assert_match a, c, strict: false end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{b: 2}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """, fn -> assert_match c, a, strict: false end

      d = 1.0
      e = 1
      f = 2

      assert_match d, e, strict: false
      assert_match e, d, strict: false

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 2
                   """,
                   fn -> assert_match d, f, strict: false end
    end

    test "strict true" do
      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 1.0
                   """,
                   fn -> assert_match 1, 1.0, strict: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 1
                   """,
                   fn -> assert_match 1.0, 1, strict: true end

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1.0, c: %{a: 1.0}}
                   right: %{a: 1, b: 2, c: %{a: 1, b: 2}}
                   """,
                   fn -> assert_match a, b, strict: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1, b: 2, c: %{a: 1, b: 2}}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """,
                   fn -> assert_match b, a, strict: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1.0, c: %{a: 1.0}}
                   right: %{b: 2}
                   """,
                   fn -> assert_match a, c, strict: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{b: 2}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """,
                   fn -> assert_match c, a, strict: true end

      d = 1.0
      e = 1
      f = 2

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 1
                   """,
                   fn -> assert_match d, e, strict: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 1.0
                   """,
                   fn -> assert_match e, d, strict: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 2
                   """,
                   fn -> assert_match d, f, strict: true end
    end

    test "with message" do
      assert_raise ExUnit.AssertionError,
                   """


                   test message
                   left:  1
                   right: 2
                   """,
                   fn -> assert_match 1, 2, message: "test message" end

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert_raise ExUnit.AssertionError, fn -> assert_match a, b, strict: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match b, a, strict: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match a, c, strict: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match c, a, strict: true end

      d = 1.0
      e = 1
      f = 2

      assert_raise ExUnit.AssertionError, fn -> assert_match d, e, strict: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match e, d, strict: true end
      assert_raise ExUnit.AssertionError, fn -> assert_match d, f, strict: true end
    end
  end

  describe "refute_match?/2" do
    test "values" do
      refute_match 1, 2

      assert_raise ExUnit.AssertionError,
                   "\n\nmatch (refute_match) succeeded, but should have failed\n",
                   fn -> refute_match 1, 1 end
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

    test "strict false" do
      assert_raise ExUnit.AssertionError, fn -> refute_match 1, 1.0, strict: false end
      assert_raise ExUnit.AssertionError, fn -> refute_match 1.0, 1, strict: false end

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{b: 2}
      c = %{a: 1.0}

      refute_match a, b, strict: false
      refute_match b, a, strict: false
      refute_match a, c, strict: false
      assert_raise ExUnit.AssertionError, fn -> refute_match c, a, strict: false end

      d = 1.0
      e = 1
      f = 1.0

      assert_raise ExUnit.AssertionError, fn -> refute_match d, e, strict: false end
      assert_raise ExUnit.AssertionError, fn -> refute_match e, d, strict: false end
      assert_raise ExUnit.AssertionError, fn -> refute_match d, f, strict: false end
    end

    test "strict true" do
      refute_match 1, 1.0, strict: true
      refute_match 1.0, 1, strict: true

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{a: 1.0}

      refute_match a, b, strict: true
      refute_match b, a, strict: true
      refute_match a, c, strict: true
      assert_raise ExUnit.AssertionError, fn -> refute_match c, a, strict: true end

      d = 1.0
      e = 1
      f = 1.0

      refute_match d, e, strict: true
      refute_match e, d, strict: true
      assert_raise ExUnit.AssertionError, fn -> refute_match d, f, strict: true end
    end
  end
end
