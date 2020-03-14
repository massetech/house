defmodule MyLittleHomeWeb.PageController do
  use MyLittleHomeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
