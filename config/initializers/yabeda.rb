if ENV.key?("VCAP_APPLICATION")
  vcap_config = JSON.parse(ENV["VCAP_APPLICATION"])

  Yabeda.configure do
    default_tag :app, vcap_config["name"]
    default_tag :app_instance, ENV["CF_INSTANCE_INDEX"]
    default_tag :organisation, vcap_config["organization_name"]
    default_tag :space, vcap_config["space_name"]
  end
end
