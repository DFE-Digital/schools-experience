class NotifyToLogger
  def initialize(api_key = nil)
    @api_key = api_key
  end

  def send_email(template_id:, email_address:, personalisation:)
    Rails.logger.info \
      "Notify message to '#{email_address}', template_id: #{template_id}"
    Rails.logger.info personalisation.to_yaml
  end
end
