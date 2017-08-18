defmodule DextructTest do
  use ExUnit.Case

  doctest Dextruct, except: [sigil_m: 2]
  use Dextruct, fill: 0

  test "Destruct with list" do
    [a, b] <~ [1]
    assert [a, b] == [1, 0]
  end

  test "Destruct with regex" do
    [a, b] <~ Regex.run(~r/(\d+)?([A-Z]+)?/, "1", capture: :all_but_first)
    assert [a, b] == ["1", 0]
  end

  test "Destruct with map" do
    %{a: a, b: b, c: foo} <~ %{a: 1}
    assert a == 1
    assert b == 0
    assert foo == 0
  end

  test "Destruct with sigil_m" do
    ~m{a, b, c: foo} <~ %{a: 1}
    assert a == 1
    assert b == 0
    assert foo == 0
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
    ~m{a, b, c => foo} = %{a: 1, b: 2, c: 3}
  end

end
