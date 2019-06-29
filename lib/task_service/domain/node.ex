defmodule TaskService.Domain.Node do
  alias TaskService.Domain.Node

  defstruct root: nil, edges: []

  def new(root, edges \\ []) do
    %Node{root: root, edges: edges}
  end

  def visit(nodes) do
    {acc, _visited} = visit(nodes, {[], %{}})

    acc
    |> Enum.reverse()
  end

  defp visit([], {acc, visited}), do: {acc, visited}

  defp visit([node | rest], {acc, visited}) do
    {updated_acc, visited} = visit(node, {acc, visited})
    visit(rest, {updated_acc, visited})
  end

  defp visit(node = %Node{root: _root, edges: edges}, {acc, visited}) do
    result = visit(edges, {acc, visited})
    visit(Map.delete(node, :edges), result)
  end

  defp visit(%Node{root: root}, {acc, visited}) do
    unless Map.has_key?(visited, root) do
      visited = Map.put(visited, root, true)
      acc = [root | acc]
      {acc, visited}
    else
      {acc, visited}
    end
  end
end
