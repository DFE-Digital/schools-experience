class Bookings::School < ApplicationRecord
  include FullTextSearch
  include GeographicSearch

  validates :name, presence: true, length: { maximum: 128 }

  def self.table_name_prefix
    'bookings_'
  end
end
