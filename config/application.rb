require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine" # We don't need activestorage
require "action_controller/railtie"
require "action_mailer/railtie" # We don't need actionmailer
# require "action_mailbox/engine" # We don't need actionmailbox
# require "action_text/engine" # We don't need actiontext
require "action_view/railtie"
# require "action_cable/engine" # We don't need actioncable
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SchoolExperience
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    #ActiveSupport::Deprecation.silenced = true
  end
end
