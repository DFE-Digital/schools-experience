class NotifyDespatchers::Sms < NotifyDespatchers::Base
  def despatch_later!
    return unless Feature.active? :sms

    validate_personalisation!

    to.each do |phone_number|
      Notify::SmsJob.perform_later \
        to: phone_number,
        template_id: template_id,
        personalisation_json: personalisation_json
    end
  end
end
