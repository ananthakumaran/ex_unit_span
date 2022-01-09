defmodule ExUnitSpan.ChromeTrace do
  @moduledoc false

  # https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/preview
  def from_track(lanes) do
    Enum.with_index(lanes)
    |> Enum.flat_map(fn {lane, pid} ->
      Enum.flat_map(lane, fn parent ->
        module =
          Atom.to_string(parent.name)
          |> format_module()

        [
          %{
            name: module,
            pid: pid,
            tid: 0,
            ts: parent.started_at,
            ph: "B"
          },
          %{
            name: module,
            pid: pid,
            tid: 0,
            ts: parent.finished_at,
            ph: "E"
          }
          | child_trace(parent.children, pid)
        ]
      end)
    end)
  end

  defp child_trace(children, pid) do
    Enum.flat_map(children, fn child ->
      [
        %{
          name: child.name,
          pid: pid,
          tid: "test",
          ts: child.started_at,
          ph: "B"
        },
        %{
          name: child.name,
          pid: pid,
          tid: "test",
          ts: child.finished_at,
          ph: "E"
        }
      ]
    end)
  end

  defp format_module("Elixir." <> module), do: module
  defp format_module(module), do: module
end
