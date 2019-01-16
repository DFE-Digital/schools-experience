class School < ApplicationRecord

  include PgSearch
  pg_search_scope :search_by_name,
    against: %i(name),
    using: {
      tsearch: {any_word: true, prefix: true}
    }

  validates :name, presence: true, length: {maximum: 128}

end
