defmodule InventaryTraker.Accounts.UserNotifier do
  import Swoosh.Email

  alias InventaryTraker.Mailer
  alias InventaryTraker.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Inventory Tracker", "noreply@pondi.app"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update your email address - Inventory Tracker", """

    ==============================
    INVENTORY TRACKER
    ==============================

    Hi #{user.email},

    You requested to change your email address for your Inventory Tracker account.

    You can update your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this email.

    Best regards,
    The Inventory Tracker Team
    https://pondi.app

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Sign in to Inventory Tracker", """

    ==============================
    INVENTORY TRACKER
    ==============================

    Hi #{user.email},

    You requested to sign in to your Inventory Tracker account.

    Click the link below to log in securely:

    #{url}

    This link will expire in 1 hour for your security.

    If you didn't request this login, please ignore this email.

    Best regards,
    The Inventory Tracker Team
    https://pondi.app

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Welcome to Inventory Tracker - Confirm your account", """

    ==============================
    INVENTORY TRACKER
    ==============================

    Welcome to Inventory Tracker, #{user.email}!

    Thank you for creating an account. To get started, please confirm your email address by clicking the link below:

    #{url}

    Once confirmed, you'll be able to:
    • Track your inventory in real-time
    • Generate insightful reports
    • Manage orders efficiently
    • And much more!

    If you didn't create an account with us, please ignore this email.

    Welcome aboard!
    The Inventory Tracker Team
    https://pondi.app

    ==============================
    """)
  end
end
