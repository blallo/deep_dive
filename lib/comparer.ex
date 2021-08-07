defmodule DeepDive.Comparer do
  @moduledoc """
  This module holds the logic to match the keys in a data structure.
  """
  @type fuzzy_matcher :: Regex.t() | (term -> bool)
  @type matcher :: char | String.t() | atom | list | map | struct | pid | fuzzy_matcher

  @doc """
  This function retrieves the first match of `matcher` and the corresponting matching key.
  In case of no match, it returns `nil`.
  """
  @spec get_key(map, matcher) :: {term, term} | nil
  def get_key(data, %Regex{} = r) do
    Enum.reduce_while(data, nil, fn {k, v}, _ -> return_on_regex_match(k, r, v) end)
  end

  def get_key(data, f) when is_function(f, 1) do
    Enum.reduce_while(data, nil, fn {k, v}, _ ->
      if f.(k) do
        {:halt, {k, v}}
      else
        {:cont, nil}
      end
    end)
  end

  def get_key(data, key) do
    case Map.get(data, key) do
      nil ->
        nil

      v ->
        {key, v}
    end
  end

  @spec return_on_regex_match(key, Regex.t(), value) :: {:halt, {key, value}} | {:cont, nil}
        when value: term, key: term
  defp return_on_regex_match(%name{} = k, %Regex{} = r, v) do
    if to_string(name) =~ r do
      {:halt, {k, v}}
    else
      {:cont, nil}
    end
  end

  defp return_on_regex_match(k, %Regex{} = r, v) do
    if to_string(k) =~ r do
      {:halt, {k, v}}
    else
      {:cont, nil}
    end
  end

  @doc """
  This function retrieves all the matches of `matcher`. The return value is a list of the
  key-value tuples.

  Note that, if the `matcher` is not a `fuzzy_matcher` it returns the result of `Map.get(2)`,
  wrapped in a list.

  Note also that this function operates only at the first level and does not steps into the
  key values.
  """
  @spec get_all_keys(map, matcher) :: [term]
  def get_all_keys(data, %Regex{} = r) do
    Enum.reduce(data, [], fn
      {%name{} = k, v}, acc -> name |> to_string |> acc_on_regex_match(r, {k, v}, acc)
      {k, v}, acc -> k |> to_string() |> acc_on_regex_match(r, {k, v}, acc)
    end)
  end

  def get_all_keys(data, f) when is_function(f, 1) do
    Enum.reduce(data, [], fn {k, v}, acc ->
      if f.(k) do
        [{k, v} | acc]
      else
        acc
      end
    end)
  end

  def get_all_keys(data, key) do
    case Map.get(data, key, :deep_dive_placeholder_key_not_found) do
      :deep_dive_placeholder_key_not_found ->
        []

      v ->
        [{key, v}]
    end
  end

  @spec acc_on_regex_match(String.t(), Regex.t(), {term, term}, [term]) :: [term]
  defp acc_on_regex_match(k, %Regex{} = r, kv, acc) do
    if k =~ r do
      [kv | acc]
    else
      acc
    end
  end
end
