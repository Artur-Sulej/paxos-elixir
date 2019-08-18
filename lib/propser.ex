defmodule Paxos.Proposer do
  use GenServer

  ### External API

  def start_link(proposer_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    proposer_id
    |> build_name()
    |> :global.register_name(pid)

    {:ok, pid}
  end

  def run(value) do
    acceptors = Paxos.Registration.get_acceptors()
    id = Paxos.IdGenerator.next_id()
    msg = %{id: id, value: value, type: :prepare_request}

    Enum.each(acceptors, fn acceptor ->
      pid = :global.whereis_name(acceptor)
      GenServer.call(pid, msg)
    end)
  end

  ### GenServer implementation

  def init(args) do
    {:ok, args}
  end

  defp build_name(proposer_id) do
    "proposer_#{proposer_id}"
  end
end
