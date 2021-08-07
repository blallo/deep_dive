defmodule DeepDive do
  @moduledoc """
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

  The public API is the function `find_keys/2`, that is present in both the aforementioned
  modules.


  [1]: https://hexdocs.pm/absinthe/overview.html
  [2]: https://hexdocs.pm/absinthe/Absinthe.Resolution.html
  """

  @typedoc """
  The result is what `find_key` gives as output. `path_of_keys` is the (ordered) list of
  keys one should use to reach the sought key. `value_of_key` is the value associated to
  such key.
  """
  @type result :: [{path_of_keys :: [term], value_of_key :: term}]

  defmacro __using__(_) do
    quote do
      @doc """
      This is the main API of the library. It expects the data to be a map-like (or list-like)
      structure to be explored. The second argument may be a `DeepDive.Comparer.matcher`.

      This means that it may be:
        - a `Regex`: in such case the key will be matched as such; be aware that the `struct`s
          are a special case, in which the name of the struct alone is matched; also, every
          key that is not possible to transform in a `String` (i.e. everything that does not
          implement the `Strings.Chars` protocol) will make `raise` the function.
        - a function of the kind `term -> bool`: to allow a custom search logic.
        - anything else (except functions): in this case the match is done by means of `==`.
      """
      @spec find_key(term, DeepDive.Comparer.matcher()) :: unquote(__MODULE__).result()
      def find_key(data, key) do
        data
        |> find_leaf(key, [], [])
        |> Enum.reverse()
        |> List.flatten()
      end
    end
  end
end
