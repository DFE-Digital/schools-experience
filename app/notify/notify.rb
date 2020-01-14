class Notify
  attr_accessor :to
  attr_reader :invalid_fields

  def initialize(to:)
    self.to = Array.wrap(to).uniq
  end

  def despatch_later!
    validate_personalisation!

    to.each do |address|
      NotifyJob.perform_later \
        to: address,
        template_id: template_id,
        personalisation_json: personalisation.to_json
    end
  end

  class InvalidPersonalisationError < RuntimeError
    def initialize(template_id, template_name, invalid_fields)
      super "Template #{template_id}: #{template_name} - #{invalid_fields.inspect}"
    end
  end

private

  def template_id
    fail 'Not implemented'
  end

  def personalisation
    fail 'Not implemented'
  end

  def validate_personalisation!
    @invalid_fields = personalisation.map { |k, v| v.nil? ? k : nil }.compact
    return true if invalid_fields.empty?

    fail InvalidPersonalisationError.new \
      template_id, self.class.to_s, invalid_fields
  end
end
