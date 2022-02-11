class NotifyDespatchers::Sms < NotifyDespatchers::Base
  def despatch_later!
    return unless Feature.enabled? :sms

    validate_personalisation!

    to.each do |phone_number|
      number = Phonelib.parse(phone_number)
      next unless valid_mobile_number?(number)

      Notify::SmsJob.perform_later \
        to: number.sanitized,
        template_id: template_id,
        personalisation_json: personalisation_json
    end
  end

private

  def valid_mobile_number?(phone_number)
    phone_number.valid? && phone_number.types.include?(:mobile)
  end
end
