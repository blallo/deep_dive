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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `deep_dive` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:deep_dive, "~> 0.1.0"}
  ]
end
```

Documentation can be found at [https://hexdocs.pm/deep_dive](https://hexdocs.pm/deep_dive).

