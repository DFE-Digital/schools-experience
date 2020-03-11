class ServiceUpdate
  include YamlModel
  KEY_FORMAT = '%Y%m%d'.freeze
  COOKIE_KEY = 'latest-viewed-service-update'.freeze

  id_attribute :date, :date
  attribute :title, :string
  attribute :summary, :string
  attribute :html_content, :string

  class << self
    def dates; ids; end

    def latest(limit = nil)
      if limit
        dates.reverse.slice(0, limit).map(&method(:find))
      elsif (date = latest_date)
        find date
      end
    end

    def latest_date
      # This is part of the code base so shouldn't change
      dates.last
    end

    def from_param(date)
      safe_date = date.gsub(%r([^\d-]), '')
      find Date.parse(safe_date).strftime KEY_FORMAT
    end

    def cookie_key
      COOKIE_KEY
    end
  end
end
