class School < ApplicationRecord

  include FullTextSearch
  include GeographicSearch

  validates :name, presence: true, length: { maximum: 128 }

end
