defmodule RmsdemoWeb.OrderBookController do
  use RmsdemoWeb, :controller

  alias Rmsdemo.Functions.StocksName

  def index(conn, _params) do
    resp =
      HTTPoison.get(
        "https://api.bseindia.com/BseIndiaAPI/api/getScripHeaderData/w?Debtflag=&scripcode=500209&seriesid="
      )

    list = StocksName.all_stocks()

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = Poison.decode!(body)
        IO.inspect(response)
        IO.inspect(response["CurrRate"]["LTP"])
        render(conn, "index.html", list: list, ltp: response["CurrRate"]["LTP"])

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        put_status(conn, 500) |> json(%{message: "failed with 404"})

      {:error, %HTTPoison.Error{reason: reason}} ->
        put_status(conn, 500) |> json(%{message: "SMS Auth failed with reason: #{reason}"})
    end

    # for x <- list do
    # IO.inspect(list)
    # end
  end

  def selected_stock(conn, %{"stk_name" => stk_name}) do
    IO.inspect(stk_name)
    {:ok, stock} = StocksName.get_stocks_name(stk_name)
    scrpcode = stock |> Enum.map(& &1.scripcode)
    tlsrcode = List.first(scrpcode)
    IO.inspect(tlsrcode)

    resp =
      HTTPoison.get(
        "https://api.bseindia.com/BseIndiaAPI/api/getScripHeaderData/w?Debtflag=&scripcode=#{tlsrcode}&seriesid="
      )

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        response = Poison.decode!(body)
        IO.inspect(response)
        IO.inspect(response["CurrRate"]["LTP"])
        render(conn, "execute_order.html", ltp: response["CurrRate"]["LTP"])

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        put_status(conn, 500) |> json(%{message: "failed with 404"})

      {:error, %HTTPoison.Error{reason: reason}} ->
        put_status(conn, 500) |> json(%{message: "SMS Auth failed with reason: #{reason}"})
    end
  end
end
