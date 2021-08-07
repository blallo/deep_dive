defmodule DeepDive.FullWalk do
  @moduledoc nil

  use DeepDive

  alias DeepDive.Comparer

  @spec find_leaf(term, Comparer.matcher(), list_of_keys_above :: [term], DeepDive.result()) ::
          DeepDive.result()
  defp find_leaf(data, key, cur_route, global_acc) when is_struct(data),
    do: data |> Map.from_struct() |> find_leaf(key, cur_route, global_acc)

  defp find_leaf(data, key, cur_route, global_acc) when is_map(data) do
    lvl_matches =
      data
      |> Comparer.get_all_keys(key)
      |> Enum.reduce([], fn {k, v}, acc -> [{Enum.reverse([k | cur_route]), v} | acc] end)

    updated_acc =
      Enum.reduce(data, global_acc, fn
        {k, v}, acc when is_map(v) or is_list(v) ->
          [find_leaf(v, key, [k | cur_route], global_acc) | acc]

        {k, v}, acc when is_struct(v) ->
          [find_leaf(Map.from_struct(v), key, [k | cur_route], global_acc) | acc]

        _, acc ->
          acc
      end)

    Enum.concat([lvl_matches, updated_acc])
  end

  defp find_leaf(data, key, cur_route, global_acc) when is_list(data) do
    if Keyword.keyword?(data) do
      data |> Enum.into(%{}) |> find_leaf(key, cur_route, global_acc)
    else
      data
      |> Enum.with_index(fn el, idx -> {idx, el} end)
      |> Enum.into(%{})
      |> find_leaf(key, cur_route, global_acc)
    end
  end
end
