defmodule Paxos.Learner do
  use GenServer

  ### External API

  def start_link(server_name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    :global.register_name(server_name, pid)
    {:ok, pid}
  end

  ### GenServer implementation

  def init(args) do
    {:ok, args}
  end
end
