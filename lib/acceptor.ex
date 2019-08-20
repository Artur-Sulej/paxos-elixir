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

    {reply, new_state} =
      if prev_proposed == nil || prev_proposed.id < id do
        {%{id: id, previous: nil, type: :prepare_response},
         Map.put(current_state, :proposed, %{id: id, value: value})}
      else
        {%{id: id, previous: prev_proposed, type: :prepare_response}, current_state}
      end

    {:reply, reply, new_state}
  end

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  defp build_name(acceptor_id) do
    "acceptor_#{acceptor_id}"
  end
end
