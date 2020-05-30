defmodule Behold.Common.MetricsPlug do
  use Prometheus.PlugExporter
end

defmodule Behold.Common.ChecksCounter do
  use Prometheus.Metric

  def setup do
    Counter.declare(
      name: :behold_checks_total,
      help: "Number of checks executed",
      labels: [:checks]
    )

    Counter.declare(
      name: :behold_checks_success,
      help: "Number of successful checks",
      labels: [:checks_success]
    )

    Counter.declare(
      name: :behold_checks_fail,
      help: "Number of failed checks",
      labels: [:checks_fail]
    )
  end

  def inc(name, labels) do
    Counter.inc(
      name: name,
      labels: labels
    )
  end
end

defmodule Behold.Common.MetricsSetup do 
  def setup do
    Behold.Common.MetricsPlug.setup()
    Behold.Common.ChecksCounter.setup()
  end
end