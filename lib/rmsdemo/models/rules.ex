defmodule Rmsdemo.Models.Rules do
  use Memento.Table,
    attributes: [:id, :operands, :rule_function],
    type: :ordered_set,
    autoincrement: true
end
