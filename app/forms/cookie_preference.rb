class CookiePreference
  EXPIRES_IN = 30.days.freeze
  VERSION = 'v1'.freeze
  COOKIES = {
    analytics: %w(_ga _gat _gid ai_session ai_user analytics_tracking_uuid)
  }.freeze

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :analytics, :boolean
  attribute :required, :boolean, default: true

  validates :analytics, inclusion: [true, false]
  validates :required, acceptance: true

  delegate :cookie_key, :all_cookies, to: :class
  delegate :to_json, to: :attributes

  class << self
    def cookie_key
      "#{model_name.param_key}-#{VERSION}"
    end

    def from_json(json)
      new JSON.parse(json)
    end

    def from_cookie(cookie)
      cookie.present? ? from_json(cookie) : new
    end

    def all_cookies
      COOKIES.values.flatten
    end
  end

  def required=(_value)
    required
  end

  def all=(accept_all_cookies)
    return unless accept_all_cookies.to_s.in? %w(true 1)

    attributes.keys.map do |key|
      self.send :"#{key}=", true
    end
  end

  def persisted?
    true
  end

  def expires
    EXPIRES_IN.from_now
  end

  def accepted_cookies
    cookie_types = attributes.select { |_k, v| v }.keys.map(&:to_sym)
    COOKIES.slice(*cookie_types).values.flatten
  end

  def rejected_cookies
    all_cookies - accepted_cookies
  end
end
