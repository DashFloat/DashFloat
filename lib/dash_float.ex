defmodule DashFloat do
  @moduledoc """
  DashFloat keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Finder modules are what we use when we want to retrieve records
  in the database using queries that have some level of complexity
  in them and would be awkward to add as a repository function.

  More info: https://peterullrich.com/phoenix-contexts
  """
  def finder do
    quote do
      import Ecto.Query

      unquote(database_interaction())
    end
  end

  @doc """
  Repository modules contain all CRUD operations for one schema.

  The point is to keep these as simple as possible and more complex
  operations must be converted into either a `finder` or `service` module.

  More info:
    - https://martinfowler.com/eaaCatalog/repository.html
    - https://peterullrich.com/phoenix-contexts
  """
  def repository do
    quote do
      unquote(database_interaction())
    end
  end

  defp database_interaction do
    quote do
      alias DashFloat.Repo
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
