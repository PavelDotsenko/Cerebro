defmodule Cerebro.Schema do
  import Cerebro.Metadata

  @doc false
  defmacro __using__(_) do
    quote do
      import Cerebro.Schema, only: [schema: 2, field: 2, set_fields: 1]
      alias :mnesia, as: Mnesia
    end
  end

  defmacro field(name, type), do: {name, type}

  defmacro schema(name, do: fields), do: add_fields(name, fields)

  defmacro set_fields(opts) do
    quote do
      %__MODULE__{unquote(Map.to_list(opts))}
    end
  end

  defp add_fields(table_name, fields) do
    name = get_table_name(Macro.escape(table_name))
    fields = get_fields(Macro.escape(fields))

    quote do
      meta = %Cerebro.Metadata{schema: unquote(name), context: __MODULE__}

      data_fields = Enum.map(unquote(fields), fn {key, _type} -> key end)

      Module.put_attribute(__MODULE__, :field_types, unquote(fields))
      Module.put_attribute(__MODULE__, :table_fields, data_fields ++ [{:__meta__, meta}])

      defstruct Module.get_attribute(__MODULE__, :table_fields)
    end
  end

  defp get_fields(opts) do
    {_, _, [_, _, opst_list]} = opts

    Enum.map(opst_list, fn {_, _, [_, _, data]} ->
      [key, val] = data
      {key, val}
    end)
  end

  defp get_table_name(table_name) when is_atom(table_name), do: table_name
  defp get_table_name(table_name) when is_binary(table_name), do: String.to_atom(table_name)

  defp get_table_name(table_name) when is_tuple(table_name) do
    {_, _, [_, _, [name]]} = table_name

    name
  end
end
