class NotifyDespatchers::NotifyEmail < NotifyDespatchers::BaseNotifyDespatcher
  def despatch_later!
    validate_personalisation!

    to.each do |address|
      Notify::NotifyByEmailJob.perform_later \
        to: address,
        template_id: template_id,
        personalisation_json: personalisation_json
    end
  end
end
