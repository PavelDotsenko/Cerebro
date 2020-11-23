defmodule Cerebro.Changeset do
  defstruct changes: nil, errors: nil, data: nil, valid?: nil

  alias :mnesia, as: Mnesia

  defmacro __using__(_) do
    quote do
      import Cerebro.Changeset, only: [cast: 3]
    end
  end

  def cast(module, opts, permitted) do
    schema = module.__struct__.__meta__.schema
    field_types = module.__struct__.__meta__.field_types |> Map.new()
    f_opts = exist_opts(schema, opts)
    f_perm = exist_permitted(schema, permitted)

    result =
      Enum.map(f_perm, fn key ->
        type_matching(key, Map.get(f_opts, key), Map.get(field_types, key))
      end)

    errors =
      Enum.filter(result, fn {status, _} -> status == :error end)
      |> Enum.map(fn {_, [key, mess]} -> [key, mess] end)

    changes =
      Enum.filter(result, fn {status, _} -> status != :error end)
      |> Enum.filter(fn {_, val} -> val != nil end)
      |> Map.new()

    %Cerebro.Changeset{
      changes: changes,
      errors: errors,
      data: module,
      valid?: if(errors == [], do: true, else: false)
    }
  end

  defp exist_opts(schema, opts) do
    attrs = Mnesia.table_info(schema, :attributes)

    Enum.reduce(opts, [], fn {key, val}, acc ->
      if Enum.find(attrs, fn x -> x == key end), do: acc ++ [{key, val}], else: acc
    end)
    |> Map.new()
  end

  defp exist_permitted(schema, opts) do
    Enum.reduce(opts, [], fn key, acc ->
      if Enum.find(Mnesia.table_info(schema, :attributes), fn x -> x == key end),
        do: acc ++ [key],
        else: acc
    end)
  end

  defp type_matching(key, val, :atom), do: type_matching(key, val, :atom, is_atom(val))

  defp type_matching(key, val, :binary), do: type_matching(key, val, :binary, is_binary(val))

  defp type_matching(key, val, :string),
    do: type_matching(key, val, :bitstring, is_bitstring(val))

  defp type_matching(key, val, :boolean), do: type_matching(key, val, :boolean, is_boolean(val))
  defp type_matching(key, val, :float), do: type_matching(key, val, :float, is_float(val))
  defp type_matching(key, val, :integer), do: type_matching(key, val, :integer, is_integer(val))
  defp type_matching(key, val, :list), do: type_matching(key, val, :list, is_list(val))
  defp type_matching(key, val, :map), do: type_matching(key, val, :map, is_map(val))
  defp type_matching(key, val, :number), do: type_matching(key, val, :number, is_number(val))
  defp type_matching(key, val, :struct), do: type_matching(key, val, :struct, is_struct(val))
  defp type_matching(key, val, :tuple), do: type_matching(key, val, :tuple, is_tuple(val))

  defp type_matching(key, val, type, result) do
    if result do
      {key, val}
    else
      if is_nil(val) do
        {key, val}
      else
        {:error,
         [key, "The #{val} of the :#{key} field does not match the type. Expected #{type}."]}
      end
    end
  end
end
