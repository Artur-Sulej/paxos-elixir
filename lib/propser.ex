defmodule Paxos.Proposer do
  use GenServer

  ### External API

  def start_link(proposer_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)

    name = build_name(proposer_id)
    :global.register_name(name, pid)
    Paxos.Registration.register_proposer(name)

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

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  defp build_name(proposer_id) do
    "proposer_#{proposer_id}"
  end
end
