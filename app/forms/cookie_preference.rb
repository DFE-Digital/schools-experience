class CookiePreference
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :analytics, :boolean
  attribute :required, :boolean, default: true

  validates :analytics, inclusion: [true, false]
  validates :required, acceptance: true

  def persisted?
    true
  end
end
