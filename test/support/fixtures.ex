defmodule Fixtures do
  def a_task(name, opts \\ []) do
    dependencies = Keyword.get(opts, :dependencies) || []

    %{
      name: name,
      command: "touch /tmp/#{name}",
      dependencies: dependencies
    }
  end
end
