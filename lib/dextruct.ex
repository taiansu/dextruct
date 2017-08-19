defmodule Dextruct do
  @moduledoc """
  Documentation for Dextruct.
  """

  @doc """
  """
  defmacro __using__(opts \\ []) do
    quote do
      import Dextruct, unquote(Keyword.drop(opts, [:fill]))

      defmacro left <~ right when is_list(right) do
        len = length(left)
        elem = unquote(opts[:fill])
        list = fill(right, len, elem)

        quote do
          unquote(left) = unquote(list)
        end
      end

      defmacro left <~ right do
        elem = unquote(opts[:fill])
        keys_or_length = left
                         |> Macro.expand(__ENV__)
                         |> fetch_keys_or_length

        quote do
          unquote(left) = fill(unquote(right), unquote(keys_or_length), unquote(elem))
        end
      end
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> Dextruct.fill([1], 3)
      [1, nil, nil]

  ## Example

      iex> Dextruct.fill(%{a: 1}, [:a, :b, :c])
      %{a: 1, b: nil, c: nil}

  """
  @spec fill(Enum.t, integer | list, any) :: Enum.t
  def fill(enum, length_or_keys, elem \\ nil)
  def fill(list, length, elem) when is_list(list) do
    filler = List.duplicate(elem, length)

    list
    |> :erlang.++(filler)
    |> Enum.take(length)
  end
  def fill(map, keys, elem) when is_map(map) do
    filler = Map.new(keys, fn k -> {k, elem} end)

    Map.merge(filler, map)
  end

  @doc """
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

  def fetch_keys_or_length({:%{}, _, args}) do
    Keyword.keys(args)
  end
  def fetch_keys_or_length(list) when is_list(list) do
    length(list)
  end
  def fetch_keys_or_length(_ast), do: raise SyntaxError
end
