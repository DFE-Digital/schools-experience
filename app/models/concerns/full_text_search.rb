require 'active_support/concern'

module FullTextSearch
  extend ActiveSupport::Concern
  include PgSearch

  included do
    pg_search_scope :search_by_name,
      against: %i(name),
      using: {
        tsearch: { any_word: true, prefix: true }
      }
  end
end
