defmodule Rmsdemo.Functions.RuleValues do
  alias Rmsdemo.Models.RuleValues

  def create_rule_values(key,value) do
    Memento.transaction( fn ->
      rule = %RuleValues{key: key, value: value}
      Memento.Query.write(rule)
    end)
  end

  def list_rule_values() do
    Memento.transaction(fn ->
      Memento.Query.all(RuleValues)
    end)
  end


  def get_rule_values!(key) do
    IO.inspect("get_rule_values called.....")
    IO.inspect(key)
    list = Memento.transaction!(fn ->
      Memento.Query.select(RuleValues, {:==, :key, key})
    end)
    list
    # IO.inspect(list)
  end

end
