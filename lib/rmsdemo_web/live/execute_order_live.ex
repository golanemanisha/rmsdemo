defmodule RmsdemoWeb.ExecuteOrderLive do
  use RmsdemoWeb, :live_view
  alias Rmsdemo.Functions.StocksName
  alias Rmsdemo.Functions.OrderBook

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
      list: StocksName.all_stocks(),
      stk_name: "INFY",
      ltp: StocksName.selected_stock("INFY") || 0,
      order_book: OrderBook.list_all(),
      quantity: "",
      flag: false,
      status: OrderBook.return_status(1)
      )
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>RMS</h1>

    <%= for st <- @status do %>
      <span>
        <%= st.status %>
      </span>
    <% end %>
    <div>
      <div class="stat">
        <span class="name">
          <%= @stk_name %> Current Price :
        </span>
        <span class="value">
          <%= @ltp %>
        </span>
      </div>
      <div id="filter">
        <form id="change-filter" phx-change="filter">
          <div class="filters" phx-change="filter">
            <select name="stk_name">
              <%= options_for_select(Enum.map(@list, &(&1.stk_name)), @stk_name) %>
            </select>
          </div>
        </form>
      </div>
      <div id="order">
          <form phx-change="update-quantity">
            <%= @quantity %>
              quantity:
              <input
                name="quantity" value=""
              />
          </form>

        </div>
        <button phx-click="buy">
          <span>Buy</span>
        </button>
      </div>
    </div>

    """
  end

  def handle_event("filter", %{"stk_name" => stk_name,}, socket) do
    ltp =  StocksName.selected_stock(stk_name)
    params = [ltp: ltp, stk_name: stk_name]
    socket = assign(socket,params)
    {:noreply, socket}
  end

  def handle_event("update-price",  %{"price" => price}, socket) do
    params = [price: price]
    socket = assign(socket,params)
    {:noreply, socket}
  end
  def handle_event("update-quantity",  %{"quantity" => quantity}, socket) do
    params = [quantity: quantity]
    socket = assign(socket,params)
    {:noreply, socket}
  end
  def handle_event("update-placed_by",  %{ "placed_by" => placed_by}, socket) do
    params = [placed_by: placed_by]
    socket = assign(socket,params)
    {:noreply, socket}
  end

  def handle_event("buy",  _, socket) do
      IO.inspect("buy called")
      # IO.inspect("socket==>",socket)
      new_stk_name = socket.assigns.stk_name
      # new_price = socket.assigns.price
      new_quantity = socket.assigns.quantity
      # new_placed_by = socket.assigns.placed_by
      new_ltp = socket.assigns.ltp
      # order_book = socket.assigns.order_book
      ordr_id = for x <- socket.assigns.order_book do
                      x.order_id
                end
      IO.inspect(hd(ordr_id))
      params = %{
                  stk_name: new_stk_name,
                  quantity: new_quantity,
                  ltp: new_ltp,
                  order_id: hd(ordr_id)
                }
      # IO.inspect(new_stk_name)
      # IO.inspect(new_price)
      # IO.inspect(new_quantity)
      # IO.inspect(new_placed_by)
      # IO.inspect(new_ltp)

      OrderBook.store_order(params)
      # param = [flag: flag]
      # socket = assign(socket,param)
      {:noreply, socket}
    end


  # def handle_event("buy",  _, socket) do
  #   IO.inspect("buy called")
  #   # IO.inspect("socket==>",socket.assigns.stk_name)
  #   new_stk_name = socket.assigns.stk_name
  #   new_price = socket.assigns.price
  #   new_quantity = socket.assigns.quantity
  #   new_placed_by = socket.assigns.placed_by
  #   new_ltp = socket.assigns.ltp
  #   params = %{stk_name: new_stk_name,
  #               price: new_price,
  #               quanityt: new_quantity,
  #               placed_by: new_placed_by,
  #               ltp: new_ltp
  #             }
  #   # IO.inspect(new_stk_name)
  #   # IO.inspect(new_price)
  #   # IO.inspect(new_quantity)
  #   # IO.inspect(new_placed_by)
  #   # IO.inspect(new_ltp)

  #   OrderBook.apply_rule(params)
  #   # param = [flag: flag]
  #   # socket = assign(socket,param)
  #   {:noreply, socket}
  # end

end
