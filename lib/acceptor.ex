defmodule Paxos.Acceptor do
  use GenServer

  ### External API

  def start_link(acceptor_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    acceptor_id
    |> build_name()
    |> :global.register_name(pid)

    {:ok, pid}
  end

  ### GenServer implementation

  def init(args) do
    {:ok, args}
  end

  defp build_name(acceptor_id) do
    "acceptor_#{acceptor_id}"
  end
end
