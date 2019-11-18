class CookiePreference
  EXPIRES_IN = 30.days.freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :analytics, :boolean
  attribute :required, :boolean, default: true

  validates :analytics, inclusion: [true, false]
  validates :required, acceptance: true

  delegate :cookie_key, to: :class
  delegate :to_json, to: :attributes

  def self.cookie_key
    model_name.param_key
  end

  def persisted?
    true
  end

  def expires
    EXPIRES_IN.from_now
  end
end
