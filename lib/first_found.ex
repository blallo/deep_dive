defmodule DeepDive.FirstFound do
  @moduledoc nil

  use DeepDive

  alias DeepDive.Comparer

  @spec find_leaf(term, Comparer.matcher(), list_of_keys_above :: [term], DeepDive.result()) ::
          DeepDive.result()
  defp find_leaf(data, key, cur_route, global_acc) when is_struct(data),
    do: data |> Map.from_struct() |> find_leaf(key, cur_route, global_acc)

  defp find_leaf(data, key, cur_route, global_acc) when is_map(data) do
    case Comparer.get_key(data, key) do
      nil ->
        data
        |> Enum.reverse()
        |> Enum.reduce(global_acc, fn {k, v}, acc -> find_leaf(v, key, [k | cur_route], acc) end)

      {k, v} ->
        [{Enum.reverse([k | cur_route]), v} | global_acc]
    end
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

  defp find_leaf(_, _, _, global_acc), do: global_acc
end
