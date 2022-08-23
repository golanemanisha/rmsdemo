defmodule RmsdemoWeb.PageController do
  use RmsdemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
