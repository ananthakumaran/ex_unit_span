# ExUnitSpan

An ExUnit formatter to visualize test execution and find bottlenecks in your test suite.

![TRACE](https://github.com/ananthakumaran/ex_unit_span/raw/master/assets/chrome_trace.png "TRACE")

## Installation

```elixir
def deps do
  [
    {:ex_unit_span, "~> 0.1.0", only: :test}
  ]
end
```

## Usage

```bash
mix test --formatter ExUnitSpan
```

This should generate `ex_unit_span.json` file in the current
folder. Open `chrome://tracing` in chrome browser and drop the json
file.
