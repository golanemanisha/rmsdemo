defmodule Rmsdemo.Models.StocksName do
  use Memento.Table,
    attributes: [:stk_id, :stk_name, :scripcode],
    type: :ordered_set,
    autoincrement: true
end
