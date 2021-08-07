defmodule DeepDiveTest do
  use ExUnit.Case
  doctest DeepDive

  alias DeepDive.{FirstFound, FullWalk}

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
      assert FirstFound.find_key(data, :e) == [
               {[:a, :h, :i, :e], 8},
               {[:a, :f, :g, :e], 6},
               {[:a, :b, :d, 4, :e], 5},
               {[:a, :b, :d, 3, :e], 4},
               {[:a, :b, :d, 2, :n, :o, :p, :e], 3},
               {[:a, :b, :d, 1, :e], 2},
               {[:a, :b, :d, 0, :e], 1}
             ]

      assert FirstFound.find_key(data, :o) == [
               {[:a, :b, :d, 5, :o], {1, 2}},
               {[:a, :b, :d, 2, :n, :o], %{p: %{e: 3}, o: "found"}}
             ]
    end

    test "full walk", %{atom_map: data} do
      assert FullWalk.find_key(data, :e) == [
               {[:a, :h, :i, :e], 8},
               {[:a, :h, :i, :j, :l, :m, :e], 8},
               {[:a, :h, :i, :j, :k, :e], 7},
               {[:a, :f, :g, :e], 6},
               {[:a, :b, :d, 4, :e], 5},
               {[:a, :b, :d, 3, :e], 4},
               {[:a, :b, :d, 2, :n, :o, :p, :e], 3},
               {[:a, :b, :d, 1, :e], 2},
               {[:a, :b, :d, 0, :e], 1}
             ]

      assert FullWalk.find_key(data, :o) == [
               {[:a, :b, :d, 5, :o], {1, 2}},
               {[:a, :b, :d, 2, :n, :o], %{p: %{e: 3}, o: "found"}},
               {[:a, :b, :d, 2, :n, :o, :o], "found"}
             ]
    end
  end

  describe "mixed keys:" do
    test "first found", %{mixed_map: data, one: one, two: two, three: three} do
      assert FirstFound.find_key(data, :a) == [
               {['with', "many", "different", 2, :a], %DummyStruct{a: 3, b: 3}},
               {['with', "many", "different", 1, :a], 2},
               {['with', "many", "different", 0, :a], 1},
               {[one, 0, two, :a], %DummyStruct{a: 3, b: 3}},
               {[one, 0, one, :a], 2}
             ]

      assert FirstFound.find_key(data, one) == [
               {[one], [%{one => two, two => three}]}
             ]

      assert FirstFound.find_key(data, true) == [
               {[true], 1}
             ]

      assert FirstFound.find_key(data, 'with') == [
               {['with'],
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
      assert FullWalk.find_key(data, :a) == [
               {[one, 0, two, :a], %DummyStruct{a: 3, b: 3}},
               {[one, 0, two, :a, :a], 3},
               {[one, 0, one, :a], 2},
               {['with', "many", "different", 2, :a], %DummyStruct{a: 3, b: 3}},
               {['with', "many", "different", 2, :a, :a], 3},
               {['with', "many", "different", 1, :a], 2},
               {['with', "many", "different", 0, :a], 1}
             ]

      assert FullWalk.find_key(data, one) == [
               {[one, 0, one], two},
               {[one], [%{one => two, two => three}]}
             ]

      assert FullWalk.find_key(data, true) == [
               {[true], 1}
             ]

      assert FullWalk.find_key(data, 'with') == [
               {['with', "many", "different", 3, 'with'], nil},
               {['with'],
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
      assert FirstFound.find_key(data, :a) == [
               {[:a], 1}
             ]
    end

    test "full walk", %{kwlist: data} do
      assert FullWalk.find_key(data, :a) == [
               {[:c, :a], 3},
               {[:c, :d, :a], 4},
               {[:a], 1}
             ]
    end
  end
end
