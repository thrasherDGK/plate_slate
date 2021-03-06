defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end

  def create_item(_, %{input: params}, %{context: context}) do
    case context do
      %{current_user: %{role: "employee"}} ->
        with {:ok, menu_item} <- Menu.create_item(params) do
          {:ok, %{menu_item: menu_item}}
        end
      _ ->
        {:error, "unauthorized"}
    end
  end
end
