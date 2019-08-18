defmodule Paxos.Learner do
  use GenServer

  ### External API

  def start_link(learner_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)

    name = build_name(learner_id)
    :global.register_name(name, pid)
    Paxos.Registration.register_learner(name)

    {:ok, pid}
  end

  ### GenServer implementation

  def init(args) do
    {:ok, args}
  end

  defp build_name(learner_id) do
    "learner_#{learner_id}"
  end
end
