# Where registrations and sessions live while moving them from Redis to the
# database. See docs/documents/session-storage-cutover.md for the deployment
# sequence; each phase is safe to run alongside the one before it.
#
#   redis    Redis is read and is authoritative; the database is written as a
#            shadow copy. Compatible with pre-database code. Default.
#   dual     The database is read and is authoritative; Redis is still written
#            so pre-database and `redis` code keeps seeing current data.
#   database The database only. Redis is neither read nor written.
module SessionStorage
  PHASES = %w[redis dual database].freeze

  def self.phase
    Rails.configuration.x.session_storage
  end

  def self.redis_authoritative?
    phase == "redis"
  end

  def self.redis_written?
    phase != "database"
  end

  def self.database?
    phase == "database"
  end
end
