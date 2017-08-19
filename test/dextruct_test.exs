defmodule DextructTest do
  use ExUnit.Case

  use Dextruct
  doctest Dextruct, except: [:moduledoc, __using__: 1, sigil_m: 2]

  describe "use default filler" do
    test "Destruct with list" do
      [a, b] <~ [1]
      assert [a, b] == [1, nil]
    end

    test "Destruct with regex" do
      [a, b] <~ Regex.run(~r/(\d+)?([A-Z]+)?/, "1", capture: :all_but_first)
      assert [a, b] == ["1", nil]
    end

    test "Destruct and assignment" do
      [x, y, z ] = [_a, _b, _c] <~ [1]
      assert x == 1
      assert y == nil
      assert z == nil
    end

    test "Destruct with map" do
      %{a: a, b: b, c: foo} <~ %{a: 1}
      assert a == 1
      assert b == nil
      assert foo == nil
    end

    test "Destruct with sigil_m" do
      ~m{a, b, c: foo} <~ %{a: 1}
      assert a == 1
      assert b == nil
      assert foo == nil
    end

    test "fill" do
    end

    test "~m{} expands keys to map of atom" do
      ~m{a, b, c: foo} = %{a: 1, b: 2, c: 3}
      assert a == 1
      assert b == 2
      assert foo == 3
    end

    test "~m with string" do
      ~m{a, b, c => foo} = %{a: 1, b: 2, c: 3} # TODO: generate map with string keys
    end
  end
end

