defmodule Rmsdemo.Functions.StocksName do
  alias Rmsdemo.Models.StocksName

  def create_stock!(stk_name,scripcode) do
    Memento.transaction( fn ->
      stock = %StocksName{
        stk_name: stk_name,
        scripcode: scripcode,
    }
      Memento.Query.write(stock)
    end)
  end

  def all_stocks() do
   {:ok, list} =  Memento.transaction(fn ->
       Memento.Query.all(StocksName)
     end)
    #  for x <- list do
    #   IO.inspect(x.stk_id)
    # end
   list
  end

  def get_stocks_name(stk_name) do
    IO.inspect(stk_name)
  stock =Memento.transaction(fn ->
    Memento.Query.select(StocksName, {:==, :stk_name, stk_name})
          end)
    stock
  end

  def selected_stock(stk_name) do
    IO.inspect(stk_name)
   {:ok, stock} = get_stocks_name(stk_name)
   scrpcode = stock |> Enum.map(& &1.scripcode)
   tlsrcode = List.first(scrpcode)
   IO.inspect(tlsrcode)
        resp = HTTPoison.get("https://api.bseindia.com/BseIndiaAPI/api/getScripHeaderData/w?Debtflag=&scripcode=#{tlsrcode}&seriesid=")

        case resp do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            response = Poison.decode!(body)
            IO.inspect(response)
            IO.inspect(response["CurrRate"]["LTP"])
            response["CurrRate"]["LTP"]

            # {:ok, %HTTPoison.Response{status_code: 404}} ->
            #   put_status(conn, 500) |> json(%{message: "failed with 404"})
            # {:error, %HTTPoison.Error{reason: reason}} ->
            #   put_status(conn, 500) |> json(%{message: "SMS Auth failed with reason: #{reason}"})
        end
  end


  #  defp full_name(%Rmsdemo.Models.StocksName{} = list) do
  #   IO.inspect(list)
  # end

end
