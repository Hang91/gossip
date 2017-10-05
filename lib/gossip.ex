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

    for str <- args do
      IO.puts(str)
    end
  end
end
