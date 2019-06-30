defmodule Fixtures do
  def a_task(name, opts \\ []) do
    dependencies = Keyword.get(opts, :dependencies) || []
    opts = Enum.into(opts, %{})

    task = %{
      name: name,
      command: "touch /tmp/#{name}",
      dependencies: dependencies
    }

    Map.merge(task, opts)
  end
end
