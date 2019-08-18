defmodule Paxos.IdGenerator do
  use Agent
  @agent_name __MODULE__

  def start_link(proposer_id) do
    Agent.start_link(fn -> proposer_id end, name: @agent_name)
  end

  def next_id do
    Agent.get_and_update(@agent_name, fn state -> {state, state + step()} end)
  end

  defp step do
    System.get_env("PROPOSERS_COUNT")
  end
end
