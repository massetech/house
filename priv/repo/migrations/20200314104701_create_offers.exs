defmodule MyLittleHome.Repo.Migrations.CreateOffers do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :origin_id, :string
      add :agent, :string
      add :township, :string
      add :contract, :string
      add :closed_at, :utc_datetime
      add :active, :boolean, default: true
      add :size, :string
      add :sqf, :float
      add :asset, :string
      add :nb_view, :integer
      add :furnished, :boolean, default: false
      add :nb_bathroom, :integer
      add :nb_room, :integer
      add :floor_nb, :integer
      add :price, :string
      add :price_in_kyat, :float
      add :price_in_usd, :float
      add :address, :string
      add :title, :string
      add :description, :text

      timestamps()
    end

  end
end
