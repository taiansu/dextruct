defmodule Dextruct do
  @moduledoc """
  The operator `<~` imitates destructing assignment behavior like in Ruby or ES6.

  It's so obvious that pattern matching with `=` is just awesome. But less then occasionally, we still want some destructing assignment, witout MatchError, works like in other languge. Dextruct library provides a `<~` operator which imitates similar behavior, with some other goodies.

  The `<~` operator works on two senarios, List and Map.

  ### List
  For destructing assignment on List, it simply fills up the list on left hand side with filler (nil by default).

        ```elixir
        iex> [a, b, c] <~ [1, 2]
        [1, 2, nil]

        iex> c
        nil
        ```


  One of the useful example is use with `Regex`'s optional group matching. Originally it will omit the unmatched groups in the end.


          ```elixir
          iex> Regex.run(~r/(a)?(b)?(c)?(d)?/, "ab")
          ["ab", "a", "b"]

          iex> [matched, a, b, c, d] <~ Regex.run(~r/(a)?(b)?(c)?(d)?/, "ab")
          ["ab", "a", "b", nil, nil]
          ```

    ### Map
    Destructing assignment on `Map`, then as well, fill the keys missing in the right hand side map,
    with filler.

          ```elixir
          iex> %{a: a, b: b, c: c} <~ %{a: 1}
          iex> a
          1
          iex> b
          nil
          iex> c
          nil
          ```
  """

  @doc """
  Use the library.

  You can specify the filler by `fill` option while `use Dextruct`. That means you can only have one filler for each module.

          ```elixir
          def YourModule do
            use Dextruct, fill: 0
          end
          ```
  """
  defmacro __using__(opts \\ []) do
    quote do
      import Dextruct, unquote(Keyword.drop(opts, [:fill]))

      defmacro left <~ right when is_list(right) do
        len = length(left)
        filler = unquote(opts[:fill])
        list = fill(right, len, filler)

        quote do
          unquote(left) = unquote(list)
        end
      end

      defmacro left <~ right do
        filler = unquote(opts[:fill])
        keys_or_length = left
                         |> Macro.expand(__ENV__)
                         |> fetch_keys_or_length

        quote do
          unquote(left) = fill(unquote(right), unquote(keys_or_length), unquote(filler))
        end
      end
    end
  end

  @doc """
  Fill up the `List` or `Map` with the filler.

  For `List`, it takes the list and length, then fill the list upto then length with filler (`nil` by default)

  ## Examples

      ```elixir
      iex> Dextruct.fill([1], 3)
      [1, nil, nil]
      ```

  Pass the filler if you want something else.

  ## Examples

      ```elixir
      iex> Dextruct.fill([1, 2], 4, 0)
      [1, 2, 0, 0]
      ```

  For `Map`, it takes the map and a list of keys. For those keys which stay in the original map, no matter you include them in the second argument or not, this function will leave them untouched.
  ## Example

      ```elixir
      iex> Dextruct.fill(%{a: 1}, [:a, :b, :c])
      %{a: 1, b: nil, c: nil}

      # same as
      iex> Dextruct.fill(%{a: 1}, [:b, :c])
      %{a: 1, b: nil, c: nil}
      ```

  """
  @spec fill(List.t, number, any) :: List.t
  @spec fill(Map.t, List.t, any) :: Map.t
  def fill(enum, length_or_keys, filler \\ nil)
  def fill(list, length, filler) when is_list(list) do
    filler = List.duplicate(filler, length)

    list
    |> :erlang.++(filler)
    |> Enum.take(length)
  end
  def fill(map, keys, filler) when is_map(map) do
    filler = Map.new(keys, fn k -> {k, filler} end)

    Map.merge(filler, map)
  end

  @doc """
  A short-hand literal for create `Map`

        ```elixir
        iex> ~m{a, b, c: foo} = %{a: 1, b: 2, c: 3}
        %{a: 1, b: 2, c: 3}
        ```

  Please notice that this `sigil_m` might be exclude by default or even deprecate, once the
[ShortMap](https://github.com/whatyouhide/short_maps) literal becomes the de facto standard anytime in the future.
  """
  defmacro sigil_m({:<<>>, _line, [string]}, opt) do
    ast = string
          |> String.split(~r/,(?:\s)*/)
          |> Enum.map(&String.split(&1, ~r/(:\s|\s=>\s)/))
          |> Enum.map(&to_variable_ast(&1, opt))

    {:%{}, [], ast}
  end

  defp to_variable_ast([key], _opt) do
    k = String.to_atom(key)
    # unbinding variable is unhygienic
    {k, {k, [], nil}}
  end

  defp to_variable_ast([key, val], _opt) do
    {String.to_atom(key), {String.to_atom(val), [], nil}}
  end

  @doc false
  def fetch_keys_or_length({:%{}, _, args}) do
    Keyword.keys(args)
  end
  def fetch_keys_or_length(list) when is_list(list) do
    length(list)
  end
  def fetch_keys_or_length(_ast), do: raise SyntaxError
end
