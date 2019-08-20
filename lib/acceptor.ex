defmodule Paxos.Acceptor do
  use GenServer

  ### External API

  def start_link(acceptor_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], name: __MODULE__)

    name = build_name(acceptor_id)
    :global.register_name(name, pid)
    Paxos.Registration.register_acceptor(name)

    {:ok, pid}
  end

  ### GenServer implementation

  def init(args) do
    {:ok, args}
  end

  def handle_call(%{id: id, value: value, type: :prepare_request}, _, current_val) do
    IO.puts("---- handle_call #{inspect(%{id: id, value: value, type: :prepare_request})} ---")
    {:reply, current_val, current_val}
  end

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  defp build_name(acceptor_id) do
    "acceptor_#{acceptor_id}"
  end
end
