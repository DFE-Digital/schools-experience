require File.expand_path('production.rb', __dir__)
require File.join(Rails.root, 'spec', 'support', 'notify_fake_client')
require Rails.root.join("lib", "servertest", "geocoder")

Rails.application.configure do
  # Override production environment settings here

  # Don't actually attempt to delivery emails in Staging environment
  Notify.notification_class = NotifyFakeClient
end
