require File.expand_path('production.rb', __dir__)
require File.join(Rails.root, 'spec', 'support', 'notify_fake_client')

Rails.application.configure do
  # Override production environment settings here
end
