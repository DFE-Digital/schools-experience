class NotifyFakeClient
  delegate :deliveries, :reset_deliveries!, to: :class

  class << self
    def deliveries
      @deliveries ||= []
    end

    def reset_deliveries!
      @deliveries = []
    end
  end

  def initialize(api_key = nil)
    @api_key = api_key
  end

  def send_email(template_id:, email_address:, personalisation:)
    msg = {
      delivered_at: Time.zone.now,
      template_id: template_id,
      email_address: email_address,
      personalisation: personalisation
    }

    deliveries << msg

    msg
  end
end
