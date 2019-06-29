defmodule Fixtures do
  def a_task(name) do
    %{
      name: name,
      command: "touch /tmp/#{name}"
    }
  end
end
