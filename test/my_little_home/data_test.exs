defmodule MyLittleHome.DataTest do
  use MyLittleHome.DataCase

  alias MyLittleHome.Data

  describe "offers" do
    alias MyLittleHome.Data.Offer

    @valid_attrs %{contract: "some contract"}
    @update_attrs %{contract: "some updated contract"}
    @invalid_attrs %{contract: nil}

    def offer_fixture(attrs \\ %{}) do
      {:ok, offer} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Data.create_offer()

      offer
    end

    test "list_offers/0 returns all offers" do
      offer = offer_fixture()
      assert Data.list_offers() == [offer]
    end

    test "get_offer!/1 returns the offer with given id" do
      offer = offer_fixture()
      assert Data.get_offer!(offer.id) == offer
    end

    test "create_offer/1 with valid data creates a offer" do
      assert {:ok, %Offer{} = offer} = Data.create_offer(@valid_attrs)
      assert offer.contract == "some contract"
    end

    test "create_offer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_offer(@invalid_attrs)
    end

    test "update_offer/2 with valid data updates the offer" do
      offer = offer_fixture()
      assert {:ok, %Offer{} = offer} = Data.update_offer(offer, @update_attrs)
      assert offer.contract == "some updated contract"
    end

    test "update_offer/2 with invalid data returns error changeset" do
      offer = offer_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_offer(offer, @invalid_attrs)
      assert offer == Data.get_offer!(offer.id)
    end

    test "delete_offer/1 deletes the offer" do
      offer = offer_fixture()
      assert {:ok, %Offer{}} = Data.delete_offer(offer)
      assert_raise Ecto.NoResultsError, fn -> Data.get_offer!(offer.id) end
    end

    test "change_offer/1 returns a offer changeset" do
      offer = offer_fixture()
      assert %Ecto.Changeset{} = Data.change_offer(offer)
    end
  end
end
