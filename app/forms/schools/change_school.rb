module Schools
  class ChangeSchool
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id
    validates :id, presence: true
  end
end
