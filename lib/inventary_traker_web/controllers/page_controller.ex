defmodule InventaryTrakerWeb.PageController do
  use InventaryTrakerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
