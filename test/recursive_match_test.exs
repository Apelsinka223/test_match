defmodule RecursiveMatchTest do
  use ExUnit.Case
  doctest RecursiveMatch
  use RecursiveMatch

  defp fun_a(), do: 1
  defp fun_b(), do: 2
  defp fun_c(), do: 1

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

      refute match_r b, a
      refute match_r a, c
      refute match_r c, a
      assert match_r a.a, b.a
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

      assert match_r a, b
      assert match_r b, a
      refute match_r a, c
      refute match_r c, a
      refute match_r d, a
    end

    test "keyword lists" do
      a = [a: 1]
      b = [a: 1]
      c = [b: 2, a: 1]
      d = [d: 1]

      assert match_r a, b
      assert match_r b, a
      refute match_r a, c
      refute match_r c, a
      refute match_r d, a
    end

    test "exactly false" do
      assert match_r 1, 1.0, exactly: false
      assert match_r 1.0, 1, exactly: false

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert match_r a, b, exactly: false
      refute match_r b, a, exactly: false
      refute match_r a, c, exactly: false
      refute match_r c, a, exactly: false

      d = 1.0
      e = 1
      f = 2

      assert match_r d, e, exactly: false
      assert match_r e, d, exactly: false
      refute match_r d, f, exactly: false
    end

    test "exactly true" do
      assert match_r 1.0, 1.0, exactly: true
      assert match_r 1, 1, exactly: true
      refute match_r 1, 1.0, exactly: true
      refute match_r 1.0, 1, exactly: true

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      refute match_r a, b, exactly: true
      refute match_r b, a, exactly: true
      refute match_r a, c, exactly: true
      refute match_r c, a, exactly: true

      d = 1.0
      e = 1
      f = 2

      refute match_r d, e, exactly: true
      refute match_r e, d, exactly: true
      refute match_r d, f, exactly: true
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

    test "exactly false" do
      assert_match 1, 1.0, exactly: false
      assert_match 1.0, 1, exactly: false

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
                   fn -> assert_match b, a, exactly: false end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1.0, c: %{a: 1.0}}
                   right: %{b: 2}
                   """,
                   fn -> assert_match a, c, exactly: false end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{b: 2}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """, fn -> assert_match c, a, exactly: false end

      d = 1.0
      e = 1
      f = 2

      assert_match d, e, exactly: false
      assert_match e, d, exactly: false

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 2
                   """,
                   fn -> assert_match d, f, exactly: false end
    end

    test "exactly true" do
      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 1.0
                   """,
                   fn -> assert_match 1, 1.0, exactly: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 1
                   """,
                   fn -> assert_match 1.0, 1, exactly: true end

      a = %{a: 1.0, c: %{a: 1.0}}
      b = %{a: 1, b: 2, c: %{a: 1, b: 2}}
      c = %{b: 2}

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1.0, c: %{a: 1.0}}
                   right: %{a: 1, b: 2, c: %{a: 1, b: 2}}
                   """,
                   fn -> assert_match a, b, exactly: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1, b: 2, c: %{a: 1, b: 2}}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """,
                   fn -> assert_match b, a, exactly: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{a: 1.0, c: %{a: 1.0}}
                   right: %{b: 2}
                   """,
                   fn -> assert_match a, c, exactly: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  %{b: 2}
                   right: %{a: 1.0, c: %{a: 1.0}}
                   """,
                   fn -> assert_match c, a, exactly: true end

      d = 1.0
      e = 1
      f = 2

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 1
                   """,
                   fn -> assert_match d, e, exactly: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1
                   right: 1.0
                   """,
                   fn -> assert_match e, d, exactly: true end

      assert_raise ExUnit.AssertionError,
                   """


                   match (assert_match) failed
                   left:  1.0
                   right: 2
                   """,
                   fn -> assert_match d, f, exactly: true end
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
