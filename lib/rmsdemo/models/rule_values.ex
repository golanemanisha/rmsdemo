defmodule Rmsdemo.Models.RuleValues do
  use Memento.Table,
    attributes: [:id, :key, :value],
    type: :ordered_set,
    autoincrement: true
end
