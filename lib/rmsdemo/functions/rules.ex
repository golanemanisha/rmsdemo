defmodule Rmsdemo.Functions.Rules do
  alias Rmsdemo.Models.Rules

  def create_rules(operands, rule_function) do
    Memento.transaction(fn ->
      rule = %Rules{operands: operands, rule_function: rule_function}
      Memento.Query.write(rule)
    end)
  end

  def list_rules() do
    Memento.transaction(fn ->
      Memento.Query.all(Rules)
    end)
  end

  def get_rule!(rule_id) do
    list =
      Memento.transaction!(fn ->
        Memento.Query.read(Rules, rule_id)
      end)

    IO.inspect(list)
  end

  def insert_operand(changes, id) do
    IO.inspect("insert_operand called!!!!!")
    IO.inspect(changes)

    Memento.transaction(fn ->
      case Memento.Query.read(Rules, id, lock: :write) do
        %Rules{} = rule ->
          rule
          |> struct(changes)
          |> Memento.Query.write()
          |> then(&{:ok, &1})

        nil ->
          {:error, :not_found}
      end
    end)
  end

  # def delete_spread(rule_id) do
  #   Memento.transaction(fn ->
  #     Memento.Query.delete(Rules, rule_id)
  #   end)
  # end

  def insert_rule_func(changes, id) do
    IO.inspect("insert_rule_func called!!!!!")
    IO.inspect(changes)

    Memento.transaction(fn ->
      case Memento.Query.read(Rules, id, lock: :write) do
        %Rules{} = rule ->
          rule
          |> struct(changes)
          |> Memento.Query.write()
          |> then(&{:ok, &1})

        nil ->
          {:error, :not_found}
      end
    end)
  end
end
