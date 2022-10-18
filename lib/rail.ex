defmodule Rail do
  defmacro __using__([]) do
    quote do
      import Rail, only: [rail: 1, rail: 2, railp: 2]
      alias Rail.Either
    end
  end

  alias Rail.Either

  defmacro rail(head, body) do
    expanded_body = expand_body(body)

    quote do
      def unquote(head), unquote(expanded_body)
    end
  end

  defmacro railp(head, body) do
    expanded_body = expand_body(body)

    quote do
      defp unquote(head), unquote(expanded_body)
    end
  end

  defmacro rail([do: _] = body) do
    expand_body(body)
  end

  # Private

  defp expand_body([{:do, do_block} | rest]) do
    [{:do, expand_do_block(do_block)} | rest]
  end

  defp expand_do_block({:__block__, _ctx, exprs}) do
    parse_exprs(exprs)
  end

  defp expand_do_block(expr) do
    parse_exprs([expr])
  end

  defp parse_exprs(exprs) do
    {body, ret} = Enum.split(exprs, -1)

    wrapped_ret =
      quote do
        unquote(List.first(ret)) |> Either.new()
      end

    body
    |> List.foldr(wrapped_ret, fn
      {:<-, _ctx, [lhs, rhs]}, acc ->
        quote do
          unquote(rhs) |> Either.chain(fn unquote(lhs) -> unquote(acc) end)
        end

      expr, acc ->
        quote do
          unquote(expr)
          unquote(acc)
        end
    end)
  end
end