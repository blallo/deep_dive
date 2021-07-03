defmodule DeepDiveTest do
  use ExUnit.Case
  doctest DeepDive

  setup do
    atom_map = %{
      a: %{
        b: %{
          c: 1,
          d: [
            %{e: 1},
            %{e: 2},
            %{n: %{o: %{p: %{e: 3}}}},
            %{e: 4},
            %{e: 5}
          ]
        },
        f: %{g: %{e: 6}},
        h: %{i: %{j: %{k: %{e: 7}, l: %{m: %{e: 8}}}, e: 8}}
      }
    }

    %{atom_map: atom_map}
  end

  test "first found", %{atom_map: data} do
    assert DeepDive.FirstFound.find_key(data, :e) == [
             {[:a, :h, :i], 8},
             {[:a, :f, :g], 6},
             {[:a, :b, :d, 4], 5},
             {[:a, :b, :d, 3], 4},
             {[:a, :b, :d, 2, :n, :o, :p], 3},
             {[:a, :b, :d, 1], 2},
             {[:a, :b, :d, 0], 1}
           ]
  end

  test "full walk", %{atom_map: data} do
    assert DeepDive.FullWalk.find_key(data, :e) == [
             {[:a, :h, :i, :j, :l, :m], 8},
             {[:a, :h, :i, :j, :k], 7},
             {[:a, :h, :i], 8},
             {[:a, :f, :g], 6},
             {[:a, :b, :d, 4], 5},
             {[:a, :b, :d, 3], 4},
             {[:a, :b, :d, 2, :n, :o, :p], 3},
             {[:a, :b, :d, 1], 2},
             {[:a, :b, :d, 0], 1}
           ]
  end
end
