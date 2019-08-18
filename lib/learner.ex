defmodule Paxos.Learner do
  use GenServer

  ### External API

  def start_link(learner_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    learner_id
    |> build_name()
    |> :global.register_name(pid)

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
