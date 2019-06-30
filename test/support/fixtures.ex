defmodule Fixtures do
  def a_task(name, opts \\ []) do
    requires = Keyword.get(opts, :requires) || []
    opts = Enum.into(opts, %{})

    task = %{
      name: name,
      command: "touch /tmp/#{name}",
      requires: requires
    }

    Map.merge(task, opts)
  end
end
