# Registers the :database_store session store used in config/environments.
# lib/action_dispatch is not autoloaded because the store must exist before
# the middleware stack is built.
require Rails.root.join("lib", "action_dispatch", "session", "database_store")
