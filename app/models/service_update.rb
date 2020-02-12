class ServiceUpdate
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :date, :date
  attribute :title, :string
  attribute :summary, :string
  attribute :content, :string
end
