class Notify
  attr_accessor :to

  def initialize(to:)
    self.to = Array.wrap to
  end

  def despatch!
    raise caller.reject { |l| l.include? 'gem' }.first
  end

  def despatch_later!
    to.each do |address|
      NotifyJob.perform_later \
        to: address,
        template_id: template_id,
        personalisation_json: personalisation.to_json
    end
  end

private

  def template_id
    fail 'Not implemented'
  end

  def personalisation
    fail 'Not implemented'
  end
end
