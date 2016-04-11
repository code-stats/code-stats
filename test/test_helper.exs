ExUnit.start

Mix.Task.run "ecto.create", ~w(-r CodeStats.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r CodeStats.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(CodeStats.Repo)

