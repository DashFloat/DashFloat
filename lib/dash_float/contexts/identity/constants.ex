defmodule DashFloat.Identity.IdentityConstants do
  @hash_algorithm :sha256
  @rand_size 32

  @spec hash_algorithm() :: atom()
  def hash_algorithm, do: @hash_algorithm

  @spec rand_size() :: integer()
  def rand_size, do: @rand_size
end
