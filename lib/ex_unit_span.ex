defmodule ExUnitSpan do
  alias ExUnitSpan.Track
  alias ExUnitSpan.ChromeTrace
  use GenServer

  defmodule State do
    defstruct [:cli_formatter, events: []]
  end

  def init(opts) do
    {:ok, pid} = GenServer.start_link(ExUnit.CLIFormatter, opts)
    {:ok, %State{cli_formatter: pid}}
  end

  def handle_cast(event = {type, _}, state) when type in [:case_started, :case_finished] do
    GenServer.cast(state.cli_formatter, event)
    {:noreply, state}
  end

  def handle_cast({:suite_finished, run_us, load_us}, state) do
    handle_cast({:suite_finished, %{run: run_us, load: load_us, async: 0}}, state)
  end

  def handle_cast(event = {type, _}, state) do
    timestamp = System.monotonic_time(:microsecond)
    state = %{state | events: [{timestamp, event} | state.events]}
    GenServer.cast(state.cli_formatter, event)

    if type == :suite_finished do
      Enum.reverse(state.events)
      |> write_trace_file()
    end

    {:noreply, state}
  end

  defp write_trace_file(events) do
    json =
      Track.from_events(events)
      |> ChromeTrace.from_track()
      |> Jason.encode!()

    File.write!("ex_unit_span.json", json)
  end
end
