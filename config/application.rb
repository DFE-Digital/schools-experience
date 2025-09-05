require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

require "prometheus/client/data_stores/direct_file_store"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Setup Prometheus store
PROMETHEUS_DIR = "/tmp/prometheus".freeze

# Needs to clear before initializing.
Dir["#{PROMETHEUS_DIR}/*.bin"].each do |file_path|
  File.unlink(file_path)
end

file_store = Prometheus::Client::DataStores::DirectFileStore.new(dir: PROMETHEUS_DIR)
Prometheus::Client.config.data_store = file_store

module SchoolExperience
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_model.i18n_customize_full_message = true

    config.exceptions_app = routes

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "London"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
