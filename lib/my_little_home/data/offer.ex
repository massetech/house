defmodule MyLittleHome.Data.Offer do
  use Ecto.Schema
  import Ecto.{Query, Changeset}

  schema "offers" do
    field :origin_id, :string
    field :agent, :string
    field :township, :string
    field :contract, :string
    field :closed_at, :utc_datetime
    field :active, :boolean
    field :size, :string
    field :sqf, :float
    field :asset, :string
    field :nb_view, :integer
    field :furnished, :boolean
    field :nb_bathroom, :integer
    field :nb_room, :integer
    field :floor_nb, :integer
    field :price, :string
    field :price_in_kyat, :float
    field :price_in_usd, :float
    field :address, :string
    field :title, :string
    field :description, :string

    timestamps()
  end

  @required_fields ~w(contract origin_id asset township agent)a
  @optional_fields ~w(closed_at active sqf size nb_bathroom nb_room price price_in_kyat price_in_usd description nb_view furnished floor_nb address title)a

  def changeset(offer, attrs) do
    offer
      |> cast(attrs, @required_fields ++ @optional_fields)
      |> validate_required(@required_fields)
  end

  def query_offer_by_origin_id(query, origin_id, agent_name) do
    from o in query, where: o.origin_id == ^origin_id and o.agent == ^agent_name
  end

end
