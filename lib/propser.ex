defmodule Paxos.Proposer do
  use GenServer

  @acceptors_majority_count 3
  @name __MODULE__

  ### External API

  def start_link(proposer_id) do
    {:ok, pid} = GenServer.start_link(@name, [], name: @name)

    name = build_name(proposer_id)
    :global.register_name(name, pid)
    Paxos.Registration.register_proposer(name)

    {:ok, pid}
  end

  def run(value) do
    acceptors = Paxos.Registration.get_acceptors()
    id = Paxos.IdGenerator.next_id()
    msg = %{id: id, value: value, type: :prepare_request}

    responses =
      Parallel.pmap(acceptors, fn acceptor ->
        acceptor
        |> :global.whereis_name()
        |> GenServer.call(msg)
      end)

    responses = Enum.reject(responses, &is_nil/1)

    # Check: https://lamport.azurewebsites.net/pubs/paxos-simple.pdf
    if length(responses) >= @acceptors_majority_count do
      maxed = Enum.max_by(responses, & &1.id)
      msg = %{id: maxed.id, value: maxed.value, type: :accept_request}

      responses =
        Parallel.pmap(acceptors, fn acceptor ->
          acceptor
          |> :global.whereis_name()
          |> GenServer.call(msg)
        end)

      responses
    end
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
