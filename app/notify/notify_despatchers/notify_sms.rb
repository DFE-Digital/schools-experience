class NotifyDespatchers::NotifySms < NotifyDespatchers::Notify
  def despatch_later!
    super

    to.each do |phone_number|
      Notify::NotifyBySmsJob.perform_later \
        to: phone_number,
        template_id: template_id,
        personalisation_json: personalisation_json
    end
  end
end
