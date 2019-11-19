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

  class << self
    def cookie_key
      model_name.param_key
    end

    def from_json(json)
      new JSON.parse(json)
    end

    def from_cookie(cookie)
      cookie.present? ? from_json(cookie) : new
    end
  end

  def required=(_value)
    required
  end

  def persisted?
    true
  end

  def expires
    EXPIRES_IN.from_now
  end
end
