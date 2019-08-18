defmodule Paxos.App do
  use Application

  def start(_type, _args) do
    registration_node = System.get_env("REG_NODE")
    proposer_id = System.get_env("PROPOSER_ID")
    acceptor_id = System.get_env("ACCEPTOR_ID")
    learner_id = System.get_env("LEARNER_ID")

    connect_node(registration_node)
    proposer_id && Paxos.Registration.register_proposer(proposer_id)
    acceptor_id && Paxos.Registration.register_acceptor(acceptor_id)
    learner_id && Paxos.Registration.register_learner(learner_id)

    children =
      Enum.reject(
        [
          proposer_id && Paxos.Proposer,
          acceptor_id && Paxos.Acceptor,
          learner_id && Paxos.Learner
        ],
        &is_nil/1
      )

    opts = [strategy: :one_for_one, name: Paxos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp generate_server_name do
    :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end

  defp connect_node(registration_node) do
    Node.start(String.to_atom(generate_server_name), :shortnames)
    Node.connect(String.to_atom(registration_node))
    :global.sync()
  end
end
