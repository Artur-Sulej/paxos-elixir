defmodule Paxos.Client do
  def print_all do
    acceptors = Paxos.Registration.get_acceptors()

    acceptors_states =
      Enum.map(acceptors, fn acceptor ->
        pid = :global.whereis_name(acceptor)
        {acceptor, GenServer.call(pid, :get_state)}
      end)

    proposers = Paxos.Registration.get_proposers()

    proposers_states =
      Enum.map(proposers, fn proposer ->
        pid = :global.whereis_name(proposer)
        {proposer, GenServer.call(pid, :get_state)}
      end)

    {proposers_states, acceptors_states}
  end
end
