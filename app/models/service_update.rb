class ServiceUpdate
  include YamlModel

  pk_attribute :date, :date
  attribute :title, :string
  attribute :summary, :string
  attribute :content, :string

  class << self
    def dates; keys; end

    def latest
      find latest_date
    end

    def latest_date
      # This is part of the code base so shouldn't change
      @latest_date ||= dates.last
    end
  end
end
