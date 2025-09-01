defmodule InventaryTraker.Repo do
  use Ecto.Repo,
    otp_app: :inventary_traker,
    adapter: Ecto.Adapters.Postgres
end
