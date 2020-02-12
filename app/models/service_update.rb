class ServiceUpdate
  include ActiveModel::Model
  include ActiveModel::Attributes

  DATA_PATH = Rails.root.join('data', model_name.collection).freeze

  attribute :date, :date
  attribute :title, :string
  attribute :summary, :string
  attribute :content, :string

  class << self
    def find(date)
      new load_yaml(date).merge(date: date)
    end

    def latest
      find latest_date
    end

    def latest_date
      dates.last
    end

    def dates
      files.map { |f| File.basename(f, '.yml') }
    end

    def all
      dates.map(&method(:find))
    end

  private

    def load_yaml(date)
      YAML.load_file update_path date
    end

    def update_path(date)
      data_path.join "#{date}.yml"
    end

    def data_path
      DATA_PATH
    end

    def files
      Dir[data_path.join('*.yml')]
    end
  end

  def ==(other)
    other.respond_to?(:attributes) && other.attributes == self.attributes
  end
end
