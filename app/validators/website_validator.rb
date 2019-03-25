class WebsiteValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.present? && is_a_uri?(value)
      record.errors.add(attribute, "is not a valid URL")
    end
  end

private

  # ensure it's a HTTP/HTTPS uri with at least one '.' in the hostname
  # note that HTTPS inherits from HTTP
  def is_a_uri?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil? && uri.host.split(".").size > 1
  rescue URI::InvalidURIError
    false
  end
end
