defmodule Paxos.Proposer do
  use GenServer

  ### External API

  def start_link(server_name) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
    :global.register_name(server_name, pid)
    {:ok, pid}
  end

  def run(value) do
    acceptors = Paxos.Registration.get_acceptors()
    msg = %{id: 1, value: value, type: :prepare_request}

    Enum.each(acceptors, fn acceptor ->
      pid = :global.whereis_name(acceptor)
      GenServer.call(pid, msg)
    end)
  end

  ### GenServer implementation

  def init(args) do
    {:ok, args}
  end
end
