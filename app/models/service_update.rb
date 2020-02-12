class ServiceUpdate
  include YamlModel

  pk_attribute :date, :date
  attribute :title, :string
  attribute :summary, :string
  attribute :content, :string

  class << self
    def latest
      find latest_date
    end

    def latest_date
      dates.last
    end

    def dates
      keys
    end
  end
end
