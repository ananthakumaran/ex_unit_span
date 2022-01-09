# ExUnitSpan

[![CI](https://github.com/ananthakumaran/ex_unit_span/actions/workflows/ci.yml/badge.svg)](https://github.com/ananthakumaran/ex_unit_span/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/hexpm/v/ex_unit_span.svg)](https://hex.pm/packages/ex_unit_span)

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
