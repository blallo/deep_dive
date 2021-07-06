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
            %{n: %{o: %{p: %{e: 3}, o: "found"}}},
            %{e: 4},
            %{e: 5},
            %{o: {1, 2}}
          ]
        },
        f: %{g: %{e: 6}},
        h: %{i: %{j: %{k: %{e: 7}, l: %{m: %{e: 8}}}, e: 8}}
      }
    }

    one = %DummyStruct{a: 1, b: 1}
    two = %DummyStruct{a: 2, b: 2}

    three = %DummyStruct{
      a: %DummyStruct{a: 3, b: 3},
      b: nil
    }

    mixed_map = %{
      "this" => %{"is" => %{"a" => %{"nested" => 'map'}}},
      'with' => %{
        "many" => %{
          "different" => [
            one,
            two,
            three,
            %{'with' => nil}
          ]
        }
      },
      "keys" => nil,
      true => 1,
      false => 0,
      one => [%{one => two, two => three}]
    }

    kwlist = [
      a: 1,
      b: 2,
      c: %{a: 3, d: [a: 4, b: 5]}
    ]

    %{atom_map: atom_map, mixed_map: mixed_map, one: one, two: two, three: three, kwlist: kwlist}
  end

  describe "atom keys:" do
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

      assert DeepDive.FirstFound.find_key(data, :o) == [
               {[:a, :b, :d, 5], {1, 2}},
               {[:a, :b, :d, 2, :n], %{p: %{e: 3}, o: "found"}}
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

      assert DeepDive.FullWalk.find_key(data, :o) == [
               {[:a, :b, :d, 5], {1, 2}},
               {[:a, :b, :d, 2, :n, :o], "found"},
               {[:a, :b, :d, 2, :n], %{p: %{e: 3}, o: "found"}}
             ]
    end
  end

  describe "mixed keys:" do
    test "first found", %{mixed_map: data, one: one, two: two, three: three} do
      assert DeepDive.FirstFound.find_key(data, :a) == [
               {['with', "many", "different", 2], %DummyStruct{a: 3, b: 3}},
               {['with', "many", "different", 1], 2},
               {['with', "many", "different", 0], 1},
               {[one, 0, two], %DummyStruct{a: 3, b: 3}},
               {[one, 0, one], 2}
             ]

      assert DeepDive.FirstFound.find_key(data, one) == [
               {[], [%{one => two, two => three}]}
             ]

      assert DeepDive.FirstFound.find_key(data, true) == [
               {[], 1}
             ]

      assert DeepDive.FirstFound.find_key(data, 'with') == [
               {[],
                %{
                  "many" => %{
                    "different" => [
                      one,
                      two,
                      three,
                      %{'with' => nil}
                    ]
                  }
                }}
             ]
    end

    test "full walk", %{mixed_map: data, one: one, two: two, three: three} do
      assert DeepDive.FullWalk.find_key(data, :a) == [
               {['with', "many", "different", 2, :a], 3},
               {['with', "many", "different", 2], %DummyStruct{a: 3, b: 3}},
               {['with', "many", "different", 1], 2},
               {['with', "many", "different", 0], 1},
               {[one, 0, two, :a], 3},
               {[one, 0, two], %DummyStruct{a: 3, b: 3}},
               {[one, 0, one], 2}
             ]

      assert DeepDive.FullWalk.find_key(data, one) == [
               {[one, 0], two},
               {[], [%{one => two, two => three}]}
             ]

      assert DeepDive.FullWalk.find_key(data, true) == [
               {[], 1}
             ]

      assert DeepDive.FullWalk.find_key(data, 'with') == [
               {['with', "many", "different", 3], nil},
               {[],
                %{
                  "many" => %{
                    "different" => [
                      one,
                      two,
                      three,
                      %{'with' => nil}
                    ]
                  }
                }}
             ]
    end
  end

  describe "kwlist:" do
    test "first found", %{kwlist: data} do
      assert DeepDive.FirstFound.find_key(data, :a) == [
               {[], 1}
             ]
    end

    test "full walk", %{kwlist: data} do
      assert DeepDive.FullWalk.find_key(data, :a) == [
               {[:c, :d], 4},
               {[:c], 3},
               {[], 1}
             ]
    end
  end
end
