defmodule ExUnitSpan.ChromeTraceTest do
  import ExUnitSpan.ChromeTrace
  use ExUnit.Case

  test "from_track" do
    assert from_track([]) == []

    assert from_track([
             [%{name: ProcessA, started_at: 1, finished_at: 5, children: []}],
             [
               %{
                 name: ProcessB,
                 started_at: 6,
                 finished_at: 10,
                 children: [
                   %{name: "t1", started_at: 7, finished_at: 9},
                   %{name: "t2", started_at: 9, finished_at: 10}
                 ]
               }
             ]
           ]) == [
             %{name: "ProcessA", ph: "B", pid: 0, tid: 0, ts: 1},
             %{name: "ProcessA", ph: "E", pid: 0, tid: 0, ts: 5},
             %{name: "ProcessB", ph: "B", pid: 1, tid: 0, ts: 6},
             %{name: "ProcessB", ph: "E", pid: 1, tid: 0, ts: 10},
             %{name: "t1", ph: "B", pid: 1, tid: "test", ts: 7},
             %{name: "t1", ph: "E", pid: 1, tid: "test", ts: 9},
             %{name: "t2", ph: "B", pid: 1, tid: "test", ts: 9},
             %{name: "t2", ph: "E", pid: 1, tid: "test", ts: 10}
           ]
  end
end
