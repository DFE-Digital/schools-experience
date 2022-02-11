class Feature
  class FeatureNotInConfigError < StandardError; end
  class IncorrectEnvironmentError < StandardError; end

  attr_reader :name, :description, :environments

  class << self
    def enabled?(feature_name)
      feature = all.find { |f| f.name == feature_name.to_s }

      raise Feature::FeatureNotInConfigError if feature.nil?

      feature.enabled_for?(Rails.env)
    end

    def all
      config[:features].map do |f|
        Feature.new(f[:name], f[:description], f[:enabled_for][:environments])
      end
    end

    def all_environments
      Dir.glob("./config/environments/*.rb").map { |filename| File.basename(filename, ".rb") }
    end

  private

    def config
      @config ||= JSON.parse(File.read(Rails.root.join('feature-flags.json'))).with_indifferent_access
    end
  end

  def initialize(name, description, environments)
    @name = name
    @description = description
    @environments = environments

    validate_environments
  end

  def enabled_for?(environment)
    environments.include?(environment)
  end

private

  def validate_environments
    raise IncorrectEnvironmentError if environments&.any? { |env| !env.in?(self.class.all_environments) }
  end
end
