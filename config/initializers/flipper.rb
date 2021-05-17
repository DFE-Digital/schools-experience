require 'flipper/adapters/redis'

Rails.application.configure do
  config.flipper.memoize = false
end

Flipper::UI.configure do |config|
  config.fun = false
end
