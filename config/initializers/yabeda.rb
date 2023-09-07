if Rails.env.test?
  # Default tags are not important in test but this ensures
  # our custom metrics are setup/testable.
  ENV["VCAP_APPLICATION"] ||= "{}"
end

if ENV.key?("VCAP_APPLICATION")
  vcap_config = JSON.parse(ENV["VCAP_APPLICATION"])

  Yabeda.configure do
    default_tag :app, vcap_config["name"]
    default_tag :app_instance, ENV["CF_INSTANCE_INDEX"]
    default_tag :organisation, vcap_config["organization_name"]
    default_tag :space, vcap_config["space_name"]

    group :gse do
      counter :sidekiq_heart_beat, comment: "Counter for a sidekiq job heart beat/monitoring"
      counter :invalid_authenticity_token, comment: "Counter for tracking invalid authenticity token (CSRF) errors"
    end
  end
else
  Yabeda.configure do
    default_tag :app_instance, ENV["HOSTNAME"]
    group :gse do
      counter :sidekiq_heart_beat, comment: "Counter for a sidekiq job heart beat/monitoring"
      counter :invalid_authenticity_token, comment: "Counter for tracking invalid authenticity token (CSRF) errors"
    end
  end
end
