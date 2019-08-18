defmodule Paxos.App do
  use Application

  def start(_type, _args) do
    node_id = System.get_env("NODE_ID")

    proposer = System.get_env("PROPOSER") && Paxos.Proposer
    acceptor = System.get_env("ACCEPTOR") && Paxos.Acceptor
    learner = System.get_env("LEARNER") && Paxos.Learner
    children = Enum.reject([proposer, acceptor, learner], &is_nil/1)

    opts = [strategy: :one_for_one, name: Paxos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp register_name(registration_node, server_name) do
    Node.start(String.to_atom(server_name), :shortnames)
    Node.connect(String.to_atom(registration_node))
    :global.sync()
    Paxos.Registration.add_own_name(server_name)
  end

  defp generate_server_name do
    System.get_env("SERVER_NAME") || :crypto.strong_rand_bytes(15) |> Base.url_encode64()
  end
end
