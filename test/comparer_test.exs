defmodule DeepDiveTest.Comparer do
  use ExUnit.Case

  alias DeepDive.Comparer

  setup do
    atom_map = %{a: 1, b: 2, this: 3, that: 4, Those: 5}

    one = %DummyStruct{a: 1, b: 2}

    mixed_map = %{"a" => 1, :b => 2, "this" => 3, :that => 4, Those => 5, one => 6}

    multilevel = %{a: %{b: 1}, b: %{a: 2, c: %{b: 3}}}

    %{atom: atom_map, mixed: mixed_map, multi: multilevel, one: one}
  end

  describe "get_key" do
    test "atom key", %{atom: atom_map, mixed: mixed_map} do
      assert Comparer.get_key(atom_map, :a) == {:a, 1}
      assert Comparer.get_key(mixed_map, :a) == nil
    end

    test "string key", %{atom: atom_map, mixed: mixed_map} do
      assert Comparer.get_key(atom_map, "a") == nil
      assert Comparer.get_key(mixed_map, "a") == {"a", 1}
    end

    test "regex", %{atom: atom_map, mixed: mixed_map, one: one} do
      # The order of the keys is not guaranteed to remain that of creation,
      # see: https://hexdocs.pm/elixir/1.12/Map.html
      r = ~r/^th/
      assert Comparer.get_key(atom_map, r) in [{:this, 3}, {:that, 4}]
      assert Comparer.get_key(mixed_map, r) in [{"this", 3}, {:that, 4}]

      r = ~r/Dummy/
      assert Comparer.get_key(mixed_map, r) == {one, 6}
    end

    test "function", %{atom: atom_map, mixed: mixed_map, one: one} do
      f = fn
        %DummyStruct{} -> true
        _ -> false
      end

      assert Comparer.get_key(atom_map, f) == nil
      assert Comparer.get_key(mixed_map, f) == {one, 6}
    end
  end

  describe "get_all_keys" do
    test "atom key", %{atom: atom_map, mixed: mixed_map} do
      assert Comparer.get_all_keys(atom_map, :a) == [{:a, 1}]
      assert Comparer.get_all_keys(mixed_map, :a) == []
    end

    test "string key", %{atom: atom_map, mixed: mixed_map} do
      assert Comparer.get_all_keys(atom_map, "a") == []
      assert Comparer.get_all_keys(mixed_map, "a") == [{"a", 1}]
    end

    test "regex", %{atom: atom_map, mixed: mixed_map, one: one} do
      r = ~r/^th/
      assert atom_map |> Comparer.get_all_keys(r) |> Enum.sort() == [{:that, 4}, {:this, 3}]
      assert mixed_map |> Comparer.get_all_keys(r) |> Enum.sort() == [{:that, 4}, {"this", 3}]

      r = ~r/Dummy/
      assert Comparer.get_all_keys(mixed_map, r) == [{one, 6}]
    end

    test "function", %{atom: atom_map, mixed: mixed_map, one: one} do
      f = fn
        %DummyStruct{} -> true
        _ -> false
      end

      assert Comparer.get_all_keys(atom_map, f) == []
      assert Comparer.get_all_keys(mixed_map, f) == [{one, 6}]
    end

    test "multilevel", %{multi: multi} do
      assert multi |> Comparer.get_all_keys(:a) |> Enum.sort() == [{:a, %{b: 1}}]
      assert multi |> Comparer.get_all_keys(:b) |> Enum.sort() == [{:b, %{a: 2, c: %{b: 3}}}]
      assert multi |> Comparer.get_all_keys(:c) |> Enum.sort() == []
    end
  end
end
