class Feature
  include Singleton

  class << self
    delegate :only_phase, :from_phase, :until_phase, to: :instance
    delegate :only, :from, :until, to: :instance
    delegate :enabled?, to: :instance
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

  def enabled?(feature_key)
    Array.wrap(Rails.application.config.x.features).include? feature_key
  end
end
