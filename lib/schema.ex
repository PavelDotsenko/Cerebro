defmodule Cerebro.Schema do
  import Cerebro.Metadata

  @doc false
  defmacro __using__(_) do
    quote do
      import Cerebro.Schema, only: [schema: 2, field: 2, set_fields: 1]
    end
  end

  defmacro field(name, type), do: {name, type}

  defmacro schema(name, do: fields), do: add_fields(name, fields)

  def set_fields(opts) do
    quote do
      %__MODULE__{unquote(Map.to_list(opts))}
    end
  end

  def field_types() do
    quote do
      Module.get_attribute(__MODULE__, :field_types)
    end
  end

  defp add_fields(table_name, fields) do
    name = get_table_name(Macro.escape(table_name))
    field_types = get_fields(Macro.escape(fields))
    fields = Enum.map(field_types, fn {key, _type} -> key end)

    quote do
      meta = %Cerebro.Metadata{
        schema: unquote(name),
        context: __MODULE__,
        field_types: unquote(field_types) |> Map.new()
      }

      defstruct unquote(fields) ++ [{:__meta__, meta}]
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
