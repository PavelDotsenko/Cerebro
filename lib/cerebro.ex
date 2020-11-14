defmodule Cerebro do
  def load() do
    quote do
      use Cerebro.Schema

      # import Plug.Conn
      # import PulsarWeb.Gettext
      # import PulsarWeb.Router.Helpers
    end
  end

  defmacro __using__(_), do: apply(__MODULE__, :load, [])
end
