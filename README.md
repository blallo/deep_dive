# DeepDive

This library should serve the simple aim of finding keys in deeply nested and complex
data structures used in other elixir projects.
The use case for which it has been conceived was to explore the depths of the
[Absinthe][1] [resolution structs][2], but may be useful in any such case when the
strutures at hand are complex and when such structures are built at runtime by some
intricate logic.
It is intended solely as a debugging utility, and not as a production-level tool.

## Premise

To understand the logic of the exploration algorithms offered, let's point out that any
nested structure we are talking about may be thought of as a _tree_. The _nodes_ of the
tree are either the keys in a map (or a struct), or the indices of a list. The _leaves_
of such tree are the nodes that have no more descendants. Two nodes have the same
_level_ if they have the same number of parent nodes up to the root. A set of nodes are
in the same _branch_ if they either have the same set of parent nodes up to the root or
one is ancestor of the other. In the former case, they are also at the same level.

### Elixir data structures and trees

For what concerns this small utility, the elixir data structure correspondents of the
elements of an abstract tree are maps (and structs treated as such) and lists (with
keyword lists as a special case, that is treated as maps). Any nested combination of such
structures may be explored with this library.

Any key-value relationship represents descending a level, and any keys in the same
structure are on the same branch (so the branching begins _after_ the key-value jump).
This is important to notice because, in the case of the `DeepDive.FirstFound` algorithm
that is described below, if a key is found on a level (i.e. in a map or a keyword list),
the search is halted for all the children branches attached to other keys (and this might
sound a bit unexpected).

## What's inside

It currently offers two different modules that implement a different exploration
strategy:

 - `DeepDive.FirstFound` starts a depth-first exploration and, whenever a key matches,
   adds it to the list of matches and drops the search on that branch.
 - `DeepDive.FullWalk` proceeds as the above, but does not stop on first match, rather on
   arriving at the leaves.

Both these strategies complete when they have explored the whole tree.


[1]: https://hexdocs.pm/absinthe/overview.html
[2]: https://hexdocs.pm/absinthe/Absinthe.Resolution.html


## In action

Take the following nested map

```elixir
iex> test_map = %{
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
```

Find, on any branch, the first occurence of the key `:e`

```elixir
iex> DeepDive.FirstFound.find_key(atom_map, :e)
[
  {[:a, :h, :i], 8},
  {[:a, :f, :g], 6},
  {[:a, :b, :d, 4], 5},
  {[:a, :b, :d, 3], 4},
  {[:a, :b, :d, 2, :n, :o, :p], 3},
  {[:a, :b, :d, 1], 2},
  {[:a, :b, :d, 0], 1}
]
```

Find all the occurences, instead

```elixir
iex> DeepDive.FullWalk.find_key(atom_map, :e)
[
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
```

Peek into the [tests](https://github.com/blallo/deep_dive/tree/main/test) to see more examples in action.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `deep_dive` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deep_dive, "~> 0.2.0", only: :dev}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/deep_dive](https://hexdocs.pm/deep_dive).

## Developing

Clone this repo and change what you want. If introducing new features or modifying existing
ones, please act on the tests accordingly.
Always run `mix credo` and `mix dialyzer` before opening a PR.
