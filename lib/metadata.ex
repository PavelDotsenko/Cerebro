defmodule Cerebro.Metadata do
  defstruct [:context, :schema, :field_types]

  @type context :: any

  @type t :: %__MODULE__{
          context: context,
          schema: module,
        }

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%{schema: schema, context: context}, opts) do
      entries =
        for entry <- [context, schema],
            entry != nil,
            do: to_doc(entry, opts)

      concat(["#Cerebro.Metadata<"] ++ Enum.intersperse(entries, ", ") ++ [">"])
    end
  end
end
