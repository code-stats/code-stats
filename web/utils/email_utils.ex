defmodule CodeStats.EmailUtils do
  @moduledoc """
  Utilities related to sending different emails from the system.
  """

  use Bamboo.Phoenix, view: CodeStats.EmailView

  alias CodeStats.{
    User,
    Utils,
    Mailer
  }

  @doc """
  Send password reset email with the given token to the given user.

  NOTE: User must have an email! Check before calling this function.
  """
  @spec send_password_reset_email(%User{}, String.t) :: nil
  def send_password_reset_email(user, token) do
    base_email()
    |> to(user.email)
    |> subject("Code::Stats password reset request")
    |> assign(:token, token)
    |> put_layout({CodeStats.LayoutView, :email})
    |> render(:password_reset)
    |> Mailer.deliver_later()
  end

  defp base_email() do
    new_email()
    |> from(Utils.get_conf(:email_from))
    |> put_header("Reply-To", Utils.get_conf(:reply_to))
  end
end
