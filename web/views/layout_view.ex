defmodule CodeStats.LayoutView do
  use CodeStats.Web, :view

  def get_title(conn) do
    site_name = get_conf(:site_name)

    if conn.assigns[:title] do
      "#{conn.assigns[:title]} – #{site_name}"
    else
      site_name
    end
  end
end
