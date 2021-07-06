defmodule DeepDive.FirstFound do
  @moduledoc nil

  use DeepDive

  @spec find_leaf(term, term, [term]) ::
          {:abort, term} | {:found, [{:leaf, DeepDive.result()}] | {:leaf, DeepDive.result()}}
  defp find_leaf(data, _key, acc) when not (is_map(data) or is_list(data)),
    do: {:abort, acc}

  defp find_leaf(%_{} = data, key, acc), do: data |> Map.from_struct() |> find_leaf(key, acc)

  defp find_leaf(data, key, acc) when is_map(data) do
    if Map.has_key?(data, key) do
      {:found, {:leaf, {Enum.reverse(acc), Map.get(data, key)}}}
    else
      data
      |> Enum.reduce([], fn {k, v}, acc_ ->
        case find_leaf(v, key, [k | acc]) do
          {:found, acc__} ->
            [acc__ | acc_]

          _ ->
            acc_
        end
      end)
      |> case do
        [] ->
          {:abort, acc}

        [new_acc] ->
          {:found, new_acc}

        new_acc ->
          {:found, new_acc}
      end
    end
  end

  defp find_leaf(data, key, acc) when is_list(data) do
    if Keyword.keyword?(data) do
      data |> Enum.into(%{}) |> find_leaf(key, acc)
    else
      data
      |> Enum.with_index()
      |> Enum.reduce([], fn {v, i}, acc_ ->
        case find_leaf(v, key, [i | acc]) do
          {:found, acc__} ->
            [acc__ | acc_]

          _ ->
            acc_
        end
      end)
      |> case do
        [] ->
          {:abort, acc}

        [new_acc] ->
          {:found, new_acc}

        new_acc ->
          {:found, new_acc}
      end
    end
  end
end
