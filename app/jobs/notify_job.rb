class NotifyJob < ApplicationJob
  queue_as :default

  def perform(klass, to, personalisation)
    klass
      .constantize
      .new(to: to, **JSON.parse(personalisation).symbolize_keys)
      .despatch!
  end

  def self.perform_later(notification)
    super(
      notification.class.to_s,
      notification.to,
      notification.send(:personalisation).to_json
    )
  end
end
