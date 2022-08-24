defmodule Rmsdemo.Functions.OrderBook do
  alias Rmsdemo.Models.OrderBook
  alias Rmsdemo.Functions.Rules
  alias Rmsdemo.Functions.RuleValues

  def create_order(
        placed_by,
        exchange_order_id,
        parent_order_id,
        status,
        status_message,
        status_message_raw,
        order_timestamp,
        exchange_update_timestamp,
        exchange_timestamp,
        variety,
        exchange,
        tradingsymbol,
        instrument_token,
        order_type,
        transaction_type,
        validity,
        product,
        quantity,
        disclosed_quantity,
        price,
        trigger_price,
        average_price,
        filled_quantity,
        pending_quantity,
        cancelled_quantity,
        market_protection,
        meta,
        tag,
        guid
      ) do
    Memento.transaction(fn ->
      order = %OrderBook{
        placed_by: placed_by,
        exchange_order_id: exchange_order_id,
        parent_order_id: parent_order_id,
        status: status,
        status_message: status_message,
        status_message_raw: status_message_raw,
        order_timestamp: order_timestamp,
        exchange_update_timestamp: exchange_update_timestamp,
        exchange_timestamp: exchange_timestamp,
        variety: variety,
        exchange: exchange,
        tradingsymbol: tradingsymbol,
        instrument_token: instrument_token,
        order_type: order_type,
        transaction_type: transaction_type,
        validity: validity,
        product: product,
        quantity: quantity,
        disclosed_quantity: disclosed_quantity,
        price: price,
        trigger_price: trigger_price,
        average_price: average_price,
        filled_quantity: filled_quantity,
        pending_quantity: pending_quantity,
        cancelled_quantity: cancelled_quantity,
        market_protection: market_protection,
        meta: meta,
        tag: tag,
        guid: guid
      }

      IO.inspect(order)
      Memento.Query.write(order)
    end)
  end

  def list_all() do
    {:ok, list} =
      Memento.transaction(fn ->
        Memento.Query.all(OrderBook)
      end)

    list
    # for x <- list do
    #     IO.inspect(x.exchange)
    # end
    # IO.inspect("order book")
    # IO.inspect(list)
  end

  def apply_rules(qty, ltp, order_id, changes) do
    IO.inspect("apply rules called.....")
    rule = Rules.get_rule!(1)
    {rule_fxn, _} = Code.eval_string(rule.rule_function)
    IO.inspect("state #{inspect(changes)}, on #{rule.operands}")
    limit = 100_000
    limit_val = RuleValues.get_rule_values!("exposure_limit")
    IO.inspect("limit val =====>")

    val =
      for x <- limit_val do
        x.value
      end

    limit_value = hd(val)
    IO.inspect(limit_value)
    status = apply(rule_fxn, [qty, ltp, limit_value])
    # IO.inspect(status)
    if status do
      changes = %{status: "PASS"}
      store_status(changes, 1)
    else
      changes = %{status: "REJECT"}
      store_status(changes, 1)
    end

    # changes = %{operands: changes}
    # Rules.insert_operand(changes,1)
    # {rule_fxn, _} = Code.eval_string()
    # total_amt = qty * ltp
    # limit = 100000
    # IO.inspect(total_amt)

    # if total_amt > limit do
    #   changes = %{
    #     status: "REJECT"
    #   }
    #   changes
    # else
    #   changes = %{
    #     status: "PASS"
    #   }
    #   changes
    # end
  end

  def store_qty_price(qty, ltp, order_id) do
    IO.inspect("store_qty_price")
    IO.inspect(qty)
    IO.inspect(ltp)

    changes = %{
      quantity: qty,
      price: ltp
    }

    Memento.transaction(fn ->
      case Memento.Query.read(OrderBook, order_id, lock: :write) do
        %OrderBook{} = order ->
          order
          |> struct(changes)
          |> Memento.Query.write()
          |> then(&{:ok, &1})

        nil ->
          {:error, :not_found}
      end
    end)

    changes = apply_rules(qty, ltp, order_id, changes)
    # IO.inspect("Result after applying rules")
    # IO.inspect(changes)
    # Memento.transaction(fn ->
    #   case Memento.Query.read(OrderBook, order_id, lock: :write) do
    #     %OrderBook{} = order ->
    #       order
    #       |> struct(changes)
    #       |> Memento.Query.write()
    #       |> then(&{:ok, &1})

    #     nil ->
    #       {:error, :not_found}
    #   end
    # end)
  end

  def store_order(params) do
    IO.inspect("store order.......")
    IO.inspect(params)
    qty = String.to_integer(params.quantity)
    ltp = String.to_float(params.ltp)
    order_id = params.order_id
    store_qty_price(qty, ltp, order_id)
  end

  def store_status(changes, order_id) do
    IO.inspect("store_status called")

    Memento.transaction(fn ->
      case Memento.Query.read(OrderBook, order_id, lock: :write) do
        %OrderBook{} = order ->
          order
          |> struct(changes)
          |> Memento.Query.write()
          |> then(&{:ok, &1})

        nil ->
          {:error, :not_found}
      end
    end)
  end

  def return_status(order_id) do
    {:ok, order_data} =
      Memento.transaction(fn ->
        Memento.Query.select(OrderBook, {:==, :order_id, 1})
      end)

    order_data
  end
end
