defmodule Paxos.Acceptor do
  use GenServer

  ### External API

  def start_link(acceptor_id) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    name = build_name(acceptor_id)
    :global.register_name(name, pid)
    Paxos.Registration.register_acceptor(name)

    {:ok, pid}
  end

  ### GenServer implementation

  def init(_args) do
    {:ok, %{accepted: [], proposed: nil}}
  end

  def handle_call(
        %{id: id, value: value, type: :prepare_request},
        _from,
        current_state = %{proposed: prev_proposed}
      ) do
    IO.puts("---- #{inspect(%{id: id, value: value, type: :prepare_request})} ---")

    if prev_proposed == nil || prev_proposed.id < id do
      reply = %{id: id, previous: prev_proposed, type: :prepare_response}
      new_state = Map.put(current_state, :proposed, %{id: id, value: value})
      {:reply, reply, new_state}
    else
      {:reply, nil, current_state}
    end
  end

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  defp build_name(acceptor_id) do
    "acceptor_#{acceptor_id}"
  end
end
