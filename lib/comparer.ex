defmodule DeepDive.Comparer do
  @moduledoc """
  This module holds the logic to match the keys in a data structure.
  """
  @type fuzzy_matcher :: Regex.t() | (term -> bool)
  @type matcher :: term | fuzzy_matcher

  @doc """
  This function tells if a map contains a key that match the `matcher`.

  Note that, if the `matcher` is not a `fuzzy_matcher` it behaves as `Map.has_key?/2`.
  """
  @spec has_key?(map, matcher) :: bool
  def has_key?(data, %Regex{} = r) do
    Enum.reduce_while(data, false, fn
      {%name{}, _}, _ -> name |> to_string |> match_regex(r)
      {k, _}, _ -> k |> to_string |> match_regex(r)
    end)
  end

  def has_key?(data, f) when is_function(f, 1) do
    Enum.reduce_while(data, false, fn {k, _}, _ ->
      if f.(k) do
        {:halt, true}
      else
        {:cont, false}
      end
    end)
  end

  def has_key?(data, key), do: Map.has_key?(data, key)

  @spec match_regex(String.t(), Regex.t()) :: {:halt, true} | {:cont, false}
  defp match_regex(k, %Regex{} = r) do
    if k =~ r do
      {:halt, true}
    else
      {:cont, false}
    end
  end

  @doc """
  This function retrieves the first match of `matcher`.

  Note that, if the `matcher` is not a `fuzzy_matcher` it behaves as `Map.get/2`.
  """
  @spec get_key(map, matcher) :: term
  def get_key(data, %Regex{} = r) do
    Enum.reduce_while(data, nil, fn
      {%name{}, v}, _ -> name |> to_string |> return_on_regex_match(r, v)
      {k, v}, _ -> k |> to_string |> return_on_regex_match(r, v)
    end)
  end

  def get_key(data, f) when is_function(f, 1) do
    Enum.reduce_while(data, nil, fn {k, v}, _ ->
      if f.(k) do
        {:halt, v}
      else
        {:cont, nil}
      end
    end)
  end

  def get_key(data, key), do: Map.get(data, key)

  @spec return_on_regex_match(String.t(), Regex.t(), value) :: {:halt, value} | {:cont, nil}
        when value: term
  defp return_on_regex_match(k, %Regex{} = r, v) do
    if k =~ r do
      {:halt, v}
    else
      {:cont, nil}
    end
  end

  @doc """
  This function retrieves all the matches of `matcher`. The return value is a list of the
  key-value tuples.

  Note that, if the `matcher` is not a `fuzzy_matcher` it returns the result of `Map.get(2)`,
  wrapped in a list.
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
