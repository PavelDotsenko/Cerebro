defmodule Cerebro.Metadata do
  defstruct [:context, :schema]

  @type context :: any

  @type t :: %__MODULE__{
          context: context,
          schema: module
        }

  # def inspect(%{schema: schema, context: context}, opts) do
  #   import Inspect.Algebra

  #   entries =
  #     for entry <- [context, schema],
  #         entry != nil,
  #         do: to_doc(entry, opts)

  #   concat(["#Cerebro.Metadata<"] ++ Enum.intersperse(entries, " | ") ++ [">"])
  # end

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
