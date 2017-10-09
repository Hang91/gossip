defmodule Gossip do
  @moduledoc """
  Documentation for Gossip.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Gossip.hello
      :world

  """
  def hello do
    :world
  end

  def main(args) do
    {nodeNum,args} = List.pop_at(args,0)
    {topology,args} = List.pop_at(args,0)
    algorithm = List.first(args)
    IO.puts "nodenum = #{nodeNum}, topology=#{topology}, algorithm=#{algorithm}"
    TOPOLOGIES.Server.start(String.to_integer(nodeNum),String.to_integer(topology),String.to_integer(algorithm))
  end
end
