defmodule InventaryTrakerWeb.PageController do
  use InventaryTrakerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def welcome(conn, _params) do
    render(conn, :welcome)
  end
end
