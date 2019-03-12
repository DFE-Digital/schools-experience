module Geocoder
  def self.search(*_args)
    # A point in Bury, Greater Manchester
    [Geocoder::Result::Test.new('latitude' => 53.596, 'longitude' => -2.29)]
  end
end
