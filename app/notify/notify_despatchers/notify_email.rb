class NotifyDespatchers::NotifyEmail < NotifyDespatchers::Notify
  def despatch_later!
    super

    to.each do |address|
      Notify::NotifyByEmailJob.perform_later \
        to: address,
        template_id: template_id,
        personalisation_json: personalisation_json
    end
  end
end
