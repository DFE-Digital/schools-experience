class Bookings::GeocodingRequest
  POSTCODE_REGEX = %r{([A-Z][A-HJ-Y]?\d[A-Z\d]? ?\d[A-Z]{2}|GIR ?0A{2})}.freeze

  attr_reader :formatted_request

  def initialize(search_request, region)
    request = search_request.dup
    formatted_request = format_postcode(request)
    @formatted_request = [formatted_request, region].join(", ")
  end

private

  def format_postcode(request)
    # Some postcodes (such as KT125EJ) are not valid in Google
    # Geocoding without the space in the correct place
    postcode = request.match(POSTCODE_REGEX)

    return request if postcode.nil?

    postcode = postcode.to_s
    request.gsub!(postcode, "")
    formatted_postcode = UKPostcode.parse(postcode).to_s
    request.empty? ? formatted_postcode : request.strip << " " + formatted_postcode
  end
end
