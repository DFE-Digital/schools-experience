# Stores the session hash as jsonb. Sessions hold symbols, dates and a
# DfE Sign-in userinfo object, which plain JSON would silently change, so those
# are written as {"_t": tag, ...} objects. Only the types listed here can be
# written or read: an unsupported value raises instead of being coerced, and
# decoding never instantiates a class chosen by the stored data.
class BrowserSession::PayloadType < ActiveRecord::Type::Json
  class UnsupportedValue < StandardError; end

  TAG = "_t".freeze

  def serialize(value)
    super(encode(value)) unless value.nil?
  end

  def deserialize(value)
    decoded = super
    decode(decoded) unless decoded.nil?
  end

private

  def encode(value)
    case value
    when nil, true, false, String, Integer, Float then value
    when Symbol then { TAG => "symbol", "v" => value.to_s }
    when Date then encode_date(value)
    when ActiveSupport::TimeWithZone
      { TAG => "time_with_zone", "v" => value.utc.iso8601(9), "zone" => value.time_zone.name }
    when Time then { TAG => "time", "v" => value.iso8601(9) }
    when Array then value.map { |item| encode(item) }
    when Hash then encode_hash(value)
    when OpenIDConnect::ResponseObject::UserInfo
      { TAG => "userinfo", "v" => encode_hash(value.raw_attributes) }
    else
      raise UnsupportedValue, "#{value.class} cannot be stored in a session"
    end
  end

  def encode_date(value)
    raise UnsupportedValue, "#{value.class} cannot be stored in a session" unless value.instance_of?(Date)

    { TAG => "date", "v" => value.iso8601 }
  end

  def encode_hash(hash)
    if hash.instance_of?(Hash) && hash.keys.all?(String) && !hash.key?(TAG)
      hash.transform_values { |item| encode(item) }
    elsif hash.instance_of?(Hash)
      { TAG => "hash", "v" => hash.map { |key, item| [encode(key), encode(item)] } }
    else
      raise UnsupportedValue, "#{hash.class} cannot be stored in a session"
    end
  end

  def decode(value)
    case value
    when Array then value.map { |item| decode(item) }
    when Hash then value.key?(TAG) ? decode_tagged(value) : value.transform_values { |item| decode(item) }
    else value
    end
  end

  def decode_tagged(value)
    case value[TAG]
    when "symbol" then value["v"].to_sym
    when "date" then Date.iso8601(value["v"])
    when "time" then Time.iso8601(value["v"])
    when "time_with_zone" then Time.iso8601(value["v"]).in_time_zone(value["zone"])
    when "hash" then value["v"].to_h { |key, item| [decode(key), decode(item)] }
    when "userinfo" then OpenIDConnect::ResponseObject::UserInfo.new(decode(value["v"]))
    else raise UnsupportedValue, "unknown session value tag #{value[TAG].inspect}"
    end
  end
end
