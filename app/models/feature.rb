class Feature
  include Singleton

  class << self
    delegate :only_phase, :from_phase, :until_phase, to: :instance
    delegate :only, :from, :until, to: :instance
    delegate :active?, to: :instance
  end

  def only_phase(phase_to_test)
    return false unless Integer(phase_to_test) == current_phase

    block_given? ? yield : true
  end
  alias_method :only, :only_phase

  def until_phase(phase_to_test)
    return false unless Integer(phase_to_test) >= current_phase

    block_given? ? yield : true
  end
  alias_method :until, :until_phase

  def from_phase(phase_to_test)
    return false unless Integer(phase_to_test) <= current_phase

    block_given? ? yield : true
  end
  alias_method :from, :from_phase

  def current_phase
    @current_phase ||= Integer(Rails.application.config.x.phase)
  end
  alias_method :current, :current_phase

  def current_phase=(phase)
    @current_phase = phase.nil? ? nil : Integer(phase)
  end
  alias_method :current=, :current_phase=

  def active?(feature_key)
    all_features.include? feature_key.to_sym
  end

private

  def env_features
    tokenised_env_features.compact.map(&:to_sym)
  end

  def config_features
    Array.wrap(Rails.application.config.x.features).compact.map(&:to_sym)
  end

  def all_features
    use_env_var? ? config_features + env_features : config_features
  end

  def use_env_var?
    Rails.env.test? || Rails.env.servertest?
  end

  def tokenised_env_features
    ENV['FEATURE_FLAGS'].to_s.strip.split(%r(\s+))
  end
end
