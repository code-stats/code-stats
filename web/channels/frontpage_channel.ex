defmodule CodeStats.FrontpageChannel do
  use Phoenix.Channel

  @moduledoc """
  The frontpage channel is used to send live updates of total
  XP numbers on the front page.
  """

  def join("frontpage", _params, socket) do
    {:ok, socket}
  end
end
