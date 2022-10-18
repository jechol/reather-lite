defmodule RailTest do
  use ExUnit.Case
  use Rail

  doctest Rail
  doctest Rail.Either

  defmodule Target do
    use Rail

    rail foo(a, b) do
      x = a + b
      y <- negate(a)

      x + y
    end

    rail negate(a) do
      -a
    end
  end

  test "with public foo" do
    assert {:ok, 2} == Target.foo(1, 2)
  end

  test "failed to call private bar" do
    assert_raise UndefinedFunctionError, fn ->
      Code.eval_quoted(
        quote do
          alias!(Target).bar(1)
        end
      )
    end
  end
end