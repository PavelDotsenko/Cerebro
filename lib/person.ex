defmodule MyProject.Person do
  use Cerebro

  schema :person do
    field(:id, :integer)
    field(:name, :string)
    field(:job, :string)
  end
end
