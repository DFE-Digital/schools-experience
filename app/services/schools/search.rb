class Schools::Search
  def search(query, location: nil, radius: 10)
    School
      .search(query)
      .close_to(coordinates(location), radius: radius)
  end

private

  def coordinates(location)
    if (results = Geocoder.search(location))
      School::GEOFACTORY.point(*extract_coordinates(results.first))
    end
  end

  def extract_coordinates(geocoder_result)
    [geocoder_result.data.dig('lon'), geocoder_result.data.dig('lat')]
  end
end
