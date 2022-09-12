require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq.configure_server do |_config|
  Yabeda::Prometheus::Exporter.start_metrics_server!
end
