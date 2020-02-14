class ServiceUpdate
  include YamlModel
  KEY_FORMAT = '%Y%m%d'.freeze

  id_attribute :date, :date
  attribute :title, :string
  attribute :summary, :string
  attribute :content, :string

  class << self
    def dates; ids; end

    def latest(limit = nil)
      if limit
        dates.reverse.slice(0, limit).map(&method(:find))
      else
        find latest_date
      end
    end

    def latest_date
      # This is part of the code base so shouldn't change
      @latest_date ||= dates.last
    end
  end

  def key
    date.strftime KEY_FORMAT
  end
end
