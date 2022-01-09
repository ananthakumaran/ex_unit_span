defmodule ExUnitSpan.Track do
  @moduledoc false

  defstruct [:lanes, :free_lanes, :started_at]

  def from_events(events) do
    Enum.reduce(events, %__MODULE__{}, fn event, track -> build(track, event) end)
  end

  defp build(%__MODULE__{}, {ts, {:suite_started, _}}) do
    %__MODULE__{lanes: %{}, free_lanes: %{}, started_at: ts}
  end

  defp build(
         %__MODULE__{lanes: lanes, free_lanes: free_lanes},
         {_ts, {:suite_finished, _}}
       )
       when map_size(lanes) == 0 do
    Enum.to_list(free_lanes)
    |> Enum.sort_by(fn {lane_id, _} -> lane_id end)
    |> Enum.map(fn {_, lane} -> Enum.reverse(lane) end)
  end

  defp build(
         %__MODULE__{lanes: lanes, free_lanes: free_lanes} = track,
         {ts, {:module_started, test_module}}
       ) do
    parent = %{name: test_module.name, children: [], started_at: ts - track.started_at}

    if Enum.empty?(free_lanes) do
      lanes = Map.put(lanes, map_size(lanes), [parent])
      %{track | lanes: lanes}
    else
      lane_id = Enum.min(Map.keys(free_lanes))
      {lane, free_lanes} = Map.pop!(free_lanes, lane_id)
      lanes = Map.put(lanes, lane_id, [parent | lane])
      %{track | lanes: lanes, free_lanes: free_lanes}
    end
  end

  defp build(
         %__MODULE__{lanes: lanes, free_lanes: free_lanes} = track,
         {ts, {:module_finished, test_module}}
       ) do
    {lane_id, lane} =
      Enum.find(lanes, fn {_, [parent | _]} -> parent.name == test_module.name end)

    [parent | rest] = lane

    parent =
      Map.put(parent, :finished_at, ts - track.started_at)
      |> Map.update!(:children, &Enum.reverse/1)

    free_lanes = Map.put(free_lanes, lane_id, [parent | rest])
    {_, lanes} = Map.pop!(lanes, lane_id)
    %{track | lanes: lanes, free_lanes: free_lanes}
  end

  defp build(
         %__MODULE__{lanes: lanes} = track,
         {ts, {:test_started, test}}
       ) do
    {lane_id, [parent | rest]} =
      Enum.find(lanes, fn {_, [parent | _]} -> parent.name == test.module end)

    child = %{name: test.name, started_at: ts - track.started_at}
    parent = %{parent | children: [child | parent.children]}
    lanes = Map.put(lanes, lane_id, [parent | rest])
    %{track | lanes: lanes}
  end

  defp build(
         %__MODULE__{lanes: lanes} = track,
         {ts, {:test_finished, test}}
       ) do
    {lane_id, [parent | rest]} =
      Enum.find(lanes, fn {_, [parent | _]} -> parent.name == test.module end)

    [child | rest_children] = parent.children
    child = Map.put(child, :finished_at, ts - track.started_at)
    parent = %{parent | children: [child | rest_children]}
    lanes = Map.put(lanes, lane_id, [parent | rest])
    %{track | lanes: lanes}
  end
end
