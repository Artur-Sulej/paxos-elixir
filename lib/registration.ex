defmodule Paxos.Registration do
  use Agent
  @agent_name {:global, __MODULE__}

  def start_link do
    Agent.start_link(fn -> %{proposers: [], acceptors: [], learners: []} end, name: @agent_name)
  end

  def register_proposer(proposer) do
    Agent.update(@agent_name, fn %{proposers: proposers, acceptors: acceptors, learners: learners} ->
      %{proposers: Enum.uniq([proposer | proposers]), acceptors: acceptors, learners: learners}
    end)
  end

  def register_acceptor(acceptor) do
    Agent.update(@agent_name, fn %{proposers: proposers, acceptors: acceptors, learners: learners} ->
      %{proposers: proposers, acceptors: Enum.uniq([acceptor | acceptors]), learners: learners}
    end)
  end

  def register_learner(learner) do
    Agent.update(@agent_name, fn %{proposers: proposers, acceptors: acceptors, learners: learners} ->
      %{proposers: proposers, acceptors: acceptors, learners: Enum.uniq([learner | learners])}
    end)
  end

  def get_proposers do
    Agent.get(@agent_name, & &1.proposers)
  end

  def get_acceptors do
    Agent.get(@agent_name, & &1.acceptors)
  end

  def get_learners do
    Agent.get(@agent_name, & &1.learners)
  end
end
