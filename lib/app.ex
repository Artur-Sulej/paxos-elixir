defmodule Paxos.App do
  use Application

  def start(_type, _args) do
    registration_node = System.get_env("REG_NODE")

    opts = [strategy: :one_for_one, name: Paxos.Supervisor]

    registration_node
    |> build_children()
    |> Supervisor.start_link(opts)
  end

  defp build_children(_registration_node = nil) do
    Node.start(:registration, :shortnames)

    [
      Paxos.Registration
    ]
  end

  defp build_children(registration_node) do
    connect_node(registration_node)

    proposer_id = System.get_env("PROPOSER_ID")
    acceptor_id = System.get_env("ACCEPTOR_ID")
    learner_id = System.get_env("LEARNER_ID")

    Enum.reject(
      [
        proposer_id && {Paxos.Proposer, proposer_id},
        acceptor_id && {Paxos.Acceptor, acceptor_id},
        learner_id && {Paxos.Learner, learner_id},
        proposer_id && {Paxos.IdGenerator, String.to_integer(proposer_id)}
      ],
      &is_nil/1
    )
  end

  defp generate_server_name do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end

  defp connect_node(registration_node) do
    Node.start(String.to_atom(generate_server_name()), :shortnames)
    Node.connect(String.to_atom(registration_node))
    :global.sync()
  end
end
