class Schools::Search
  # Search for schools based on a query string, location
  # and optional radius. Note, both +.search+ and +.close_to+
  # will not amend the +ActiveRecord::Relation+ if falsy values
  # or empty strings (in the case of +.search+) are passed.
  #
  # This means if one is present and not the other, the query will fall
  # back to the present value. It also means that if none are passed,
  # all schools will be returned.
  def search(query, location: nil, radius: 10)
    School
      .search(query)
      .close_to(point(location), radius: radius)
  end

private

  def point(location)
    if (result = Geocoder.search(location)&.first)
      School::GEOFACTORY.point(
        result.data.dig('lon'),
        result.data.dig('lat')
      )
    end
  end
end
