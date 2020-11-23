defmodule MyProject.Person do
  use Cerebro

  schema :person do
    field(:id, :integer)
    field(:name, :string)
    field(:job, :string)
  end

  def changeset(params \\ %{}) do
    cast(__MODULE__, params, [:id, :name, :job])
  end
end
