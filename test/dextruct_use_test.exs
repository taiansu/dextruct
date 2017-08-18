defmodule DextructUseTest do
  use ExUnit.Case
  use Dextruct, fill: 0

  describe "use different filler" do
    test "Destruct with list" do
      [a, b] <~ [1]
      assert [a, b] == [1, 0]
    end

    test "Destruct with map" do
      %{a: a, b: b, c: foo} <~ %{a: 1}
      assert a == 1
      assert b == 0
      assert foo == 0
    end
  end
end
