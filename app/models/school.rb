class School < ApplicationRecord

  include FullTextSearch
  validates :name, presence: true, length: {maximum: 128}

end
