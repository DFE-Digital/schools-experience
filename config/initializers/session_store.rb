# Registers the :database_store session store used in config/environments.
# lib/action_dispatch is not autoloaded because the store must exist before
# the middleware stack is built.
require Rails.root.join("lib", "action_dispatch", "session", "database_store")

unless %w[redis dual database].include?(Rails.configuration.x.session_storage)
  raise "SESSION_STORAGE must be one of redis, dual, database"
end
