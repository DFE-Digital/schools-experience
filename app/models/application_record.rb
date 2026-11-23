class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Serialises read-modify-write and delete operations on one logical record
  # (across Redis and the database during the storage cutover). Released when
  # the surrounding transaction ends.
  def self.with_advisory_lock(key, &block)
    transaction do
      connection.execute(
        sanitize_sql(["SELECT pg_advisory_xact_lock(hashtextextended(?, 0))", "#{table_name}:#{key}"])
      )
      block.call
    end
  end
end
