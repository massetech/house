defmodule MyLittleHome.Repo do
  use Ecto.Repo,
    otp_app: :my_little_home,
    adapter: Ecto.Adapters.Postgres
end
