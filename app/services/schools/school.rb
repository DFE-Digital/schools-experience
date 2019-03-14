module Schools
  class School
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name, :string
    attribute :urn, :integer

    validates :name, presence: true
    validates :urn, presence: true

    def self.from_json(json)
      attributes = JSON.parse(json).slice 'name', 'urn'
      new(attributes).tap(&:validate!)
    end

    def ==(other)
      other.attributes == self.attributes
    end
  end
end
