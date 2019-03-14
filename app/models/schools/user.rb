module Schools
  class User
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :first_name, :string
    attribute :last_name, :string
    attribute :email, :string

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true

    def self.from_json(json)
      attributes = JSON.parse(json).transform_keys(&:underscore)
      new(attributes).tap(&:validate!)
    end
  end
end
