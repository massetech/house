defmodule MyLittleHome.Data do
  import Ecto.Query, warn: false
  alias MyLittleHome.Repo
  alias MyLittleHome.Data.Offer

  @imh_index_url "https://www.imyanmarhouse.com/en/search"
  @imh_offer_rent_url "https://www.imyanmarhouse.com/en/rent"
  @imh_patterns %{
    title: "(?<=<title>).{1,1000}(?=.{0,1000}</title>)",
    phone_number: " 09[0-9]{0,20}",
    nb_view: "(Views.{1,50})[0-9]{1,5}(?=.{1,50}Ad Number)", # Html caption: "Views 226 |	Ad Number"
    floor_nb: "(?<=fa-building-o fa-stack-1x).{1,100}[1-9]{1,2}(?=.{0,10}Floor)", # Html caption: "7 Floor"
    nb_room: "(?<=fa-bed fa-stack-1x).{1,100}[1-9]{1,2}(?=.{0,10}Rooms)", # Html caption: "fa-bed 2 rooms"
    nb_bathroom: "(?<=fa-shower fa-stack-1x).{1,100}[1-9]{1,2}(?=.{0,10}Rooms)", # Html caption: "fa-shower 2 rooms"
    fully_furnished: "(?<=Description).{1,100}Fully Furnished", # Html caption: "Fully furnished"
    renting_price: "(Monthly Rental Fees).{1,100}1 Month", # Html caption: "Monthly Rental Fees"
    selling_price: "(Price \(Kyats\)).{1,100}Kyats\)",
    size: "(?<=Area).{1,100}(?=.{0,10}</p>)"
  }

# ------------------------     OFFER DETAILS    ----------------------------------------

  # get_imh_offer_details("172")
  def get_imh_offer_details(offer_id) do
    offer = get_offer!(offer_id)
    datas = [@imh_offer_rent_url, offer.origin_id]
      |> Enum.join("/")
      |> IO.inspect()
      |> HTTPoison.get!()
      |> process_imh_offer(offer.contract)
    case datas do
      {:ok, params} -> update_offer(offer, params)
      answer -> answer
    end

  end

  def process_imh_offer(%HTTPoison.Response{body: html_text, status_code: 200}, contract) do
    title = filter_imh_title(html_text)
    description = filter_imh_description(html_text)
    nb_view = filter_imh_nb_view(html_text)
    floor_nb = filter_imh_floor_nb(html_text)
    nb_room = filter_imh_nb_room(html_text)
    nb_bathroom = filter_imh_nb_bathroom(html_text)
    fully_furnished = test_imh_fully_furnished(html_text)
    size = filter_imh_size(html_text)
    price = case contract do
      "rent" -> filter_imh_renting_price(html_text)
      "sale" -> filter_imh_selling_price(html_text)
    end
    results = %{title: title, nb_view: nb_view, nb_room: nb_room, nb_bathroom: nb_bathroom, floor_nb: floor_nb, price: price, furnished: fully_furnished, size: size, description: description}
    {:ok, results}
  end
  def process_imh_offer(_) do
    {:error, "No answer from the get query process_imh_offer"}
  end

  def filter_imh_title(text) do
    text
      |> (&Regex.scan(~r/#{@imh_patterns.title}/, &1)).()
      |> List.flatten()
      |> List.first()
  end

  def filter_imh_description(text) do
    text
      |> (&Regex.scan(~r/#{@imh_patterns.phone_number}/, &1)).()
      |> List.flatten()
      |> Enum.join(" - ")
  end

  # filter_imh_nb_views("md-6 hidden-sm hidden-xs text-right>Views 226 |	Ad Number <strong>R-1829484")
  def filter_imh_nb_view(text) do
    text
      |> (&Regex.scan(~r/#{@imh_patterns.nb_view}/, &1)).()
      |> convert_regex_to_integer()
  end

  def convert_regex_to_integer(array) do
    result = array
      |> List.flatten()
      |> List.first()
    case result do
      nil -> nil
      string ->
        string
          |> String.replace(~r/[^\d]/, "")
          |> String.to_integer()
    end
  end

  # filter_imh_floor_nb("1x fa-inverse></i></span>&nbsp;7th Floor</span> <span class=p-r-15><span cl")
  def filter_imh_floor_nb(text) do
    text
      |> (&Regex.scan(~r/#{@imh_patterns.floor_nb}/, &1)).()
      |> convert_regex_to_integer()
  end

  # filter_imh_nb_rooms("dededededdedededdeefa fa-bed fa-stack-1x fa-inverse></i> </span>	3 Rooms</span> </p></di")
  def filter_imh_nb_room(text) do
    text
      |> (&Regex.scan(~r/#{@imh_patterns.nb_room}/, &1)).()
      |> convert_regex_to_integer()
  end

  # filter_imh_nb_bathrooms("dededededdedededdeefa fa-bath fa-stack-1x fa-inverse></i> </span>	3 Rooms</span> </p></di")
  def filter_imh_nb_bathroom(text) do
    text
      |> (&Regex.scan(~r/#{@imh_patterns.nb_bathroom}/, &1)).()
      |> convert_regex_to_integer()
  end

  # filter_imh_price("ATUS + PRICE --><div class=col-sm-4><div><h5 class=text-capitalize text-bold>Monthly Rental Fees</h5><p class=fs-18>9 Lakh (Kyats) (1 Month)</p></div><")
  def filter_imh_renting_price(text) do
    result = text
      |> (&Regex.scan(~r/#{@imh_patterns.renting_price}/, &1)).()
      |> List.flatten()
      |> List.first()
  end
  def filter_imh_selling_price(text) do
    text
    result = text
      |> (&Regex.scan(~r/#{@imh_patterns.renting_price}/, &1)).()
      |> List.flatten()
      |> List.first()
  end

  # test_imh_fully_furnished("eck-circle text-orange'></i> Fully Furnished</li></ul></div>")
  def test_imh_fully_furnished(text) do
    result = text
      |> (&Regex.scan(~r/#{@imh_patterns.fully_furnished}/, &1)).()
      |> List.flatten()
      |> List.first()
    if result == nil, do: false, else: true end

  def filter_imh_size(text) do
    result = text
      |> (&Regex.scan(~r/#{@imh_patterns.size}/, &1)).()
      |> List.flatten()
      |> List.first()
  end

  # ------------------------     OFFERS INDEX    ----------------------------------------

  # get_imh_index_all("rent", "yangon-region", "ahlone", "condo", 5)
  def get_imh_index_all(contract, region, township, asset_kind, nb_pages) do
    for i <- 1..nb_pages, do: get_imh_index(contract, region, township, asset_kind, "page#{i}")
  end

  # get_imh_index("rent", "yangon-region", "ahlone", "condo", "page1")
  # get_imh_index("sale", "yangon-region", "ahlone", "condo", "page1")
  def get_imh_index(contract, region, township, asset_kind, page) do
    case contract do
      "rent" ->
        [@imh_index_url, "for-rent", region, township, asset_kind, "sortBy-new-to-old", page]
          |> Enum.join("/")
          |> IO.inspect()
          |> HTTPoison.get!()
          |> process_imh_index("rent", page)
          |> save_new_offers("imh", "rent", township, asset_kind, page)
      "sale" ->
        [@imh_index_url, "for-sale", region, township, asset_kind, "sortBy-new-to-old", page]
          |> Enum.join("/")
          |> IO.inspect()
          |> HTTPoison.get!()
          |> process_imh_index("sale", page)
          |> save_new_offers("imh", "rent", township, asset_kind, page)
    end
  end
  def process_imh_index(%HTTPoison.Response{body: body, status_code: 200}, contract, page) do
    #IO.inspect("Results for imh_index #{page}")
    result = body
      |> (&Regex.scan(~r/data-href=.{1,3}\/en\/#{contract}\/[0-9]*/, &1)).()
      |> List.flatten()
      |> Enum.map(fn x -> Regex.scan(~r/\d[0-9]*/, x) end)
      |> List.flatten()
      #|> IO.inspect()
    case result do
      [] -> {:error, result}
      _ -> {:ok, result}
    end
  end
  def process_imh_index(_, contract, page) do
    {:error, "No answer from the query for imh_index #{contract} #{page}"}
  end

  # save_new_offers({:ok, ["18321472", "18320740"]}, "imh", "for-rent", "ahlone", "condo")
  def save_new_offers({:ok, list}, agent_name, contract, township, asset_kind, page) do
    results = Enum.map(list, &create_new_offer(&1, agent_name, contract, township, asset_kind))
    nb_nothing = Enum.count(results, &(elem(&1,0) == :nothing))
    nb_new = Enum.count(results, &(elem(&1,0) == :ok))
    nb_error = Enum.count(results, &(elem(&1,0) == :error))
    {:ok, "Result for #{page}: #{nb_new} offers created, #{nb_nothing} offers already existed, #{nb_error} errors on saving"}
  end
  # save_new_offers({:error, "No answer from the query for...}, "imh", "for-rent", "ahlone", "condo")
  def save_new_offers(answer, _, _, _, _, _), do: answer

  # save_offer("18321472", "imh", "for-rent", "yangon-region", "ahlone", "condo")
  def create_new_offer(origin_id, agent_name, contract, township, asset_kind) do
    #origin_id = "#{agent_name}_#{id}"
    case get_offer_by_origin_id(origin_id, agent_name) do
      nil -> create_offer(%{origin_id: origin_id, agent: agent_name, contract: contract, township: township, asset: asset_kind})
      _ -> {:nothing, "#{agent_name} offer #{origin_id} already existed"}
    end
  end



  def list_offers do
    Repo.all(Offer)
  end

  def get_offer!(id), do: Repo.get!(Offer, id)

  def get_offer_by_origin_id(origin_id, agent_name) do
    Offer
      |> Offer.query_offer_by_origin_id(origin_id, agent_name)
      |> Repo.one()
  end

  def create_offer(attrs \\ %{}) do
    %Offer{}
    |> Offer.changeset(attrs)
    |> Repo.insert()
  end

  def update_offer(%Offer{} = offer, attrs) do
    offer
    |> Offer.changeset(attrs)
    |> Repo.update()
  end

  def delete_all_offers() do
    Offer
      |> Repo.delete_all()
  end

  def delete_offer(%Offer{} = offer) do
    Repo.delete(offer)
  end

  def change_offer(%Offer{} = offer) do
    Offer.changeset(offer, %{})
  end
end
