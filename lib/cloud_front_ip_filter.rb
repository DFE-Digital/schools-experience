class CloudFrontIpFilter
  def self.configure!
    Rack::Request.ip_filter = new(Rack::Request.ip_filter)
  end

  def initialize(original_filter = nil)
    @original_filter = original_filter
  end

  def call(ip)
    @original_filter.call(ip) || cloudfront_ip?(ip)
  end

private

  def cloudfront_ip?(ip)
    cloudfront_proxies.any? do |range|
      range.include? ip
    end
  rescue IPAddr::InvalidAddressError
    # Malformed X-Forwarded-For entries (e.g. empty tokens from a stray
    # comma) reach here as invalid addresses; treat them as untrusted.
    false
  end

  def cloudfront_proxies
    ActionPack::Cloudfront::IpRanges.cloudfront_proxies
  end
end
