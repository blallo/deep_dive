defmodule DeepDive.FullWalk do
  @moduledoc nil

  use DeepDive

  @spec find_leaf(term, term, [term]) ::
          {:abort, term} | {:found, [{:leaf, DeepDive.result()}] | {:leaf, DeepDive.result()}}
  defp find_leaf(data, _key, acc) when not (is_map(data) or is_list(data)),
    do: {:abort, acc}

  defp find_leaf(%_{} = data, key, acc), do: data |> Map.from_struct() |> find_leaf(key, acc)

  defp find_leaf(data, key, acc) when is_map(data) do
    data
    |> Enum.reduce([], fn
      {^key, v}, acc_ when not is_map(v) and not is_list(v) ->
        [{:leaf, {Enum.reverse(acc), v}} | acc_]

      {^key, v}, acc_ ->
        acc_ = [{:leaf, {Enum.reverse(acc), v}} | acc_]

        case find_leaf(v, key, [key | acc]) do
          {:found, acc__} ->
            [acc__ | acc_]

          _ ->
            acc_
        end

      {k, v}, acc_ ->
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
