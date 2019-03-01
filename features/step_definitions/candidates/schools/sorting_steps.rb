Given("there there are schools with the following attributes:") do |table|
  def locate(place)
    {
      "Manchester" => Bookings::School::GEOFACTORY.point(-2.241, 53.481),
      "Rochdale" => Bookings::School::GEOFACTORY.point(-2.150, 53.615),
      "Burnley" => Bookings::School::GEOFACTORY.point(-2.243, 53.788)
    }[place]
  end

  @schools = table.hashes.each.with_object([]) do |attributes, schools|
    schools << FactoryBot.create(
      :bookings_school,
      name: attributes["Name"],
      fee: attributes["Fee"].to_i,
      coordinates: locate(attributes["Location"])
    )
  end

  expect(Bookings::School.count).to eql(table.rows.length)
end

Then("the results should be sorted by fee, lowest to highest") do
  expect(
    page
      .all('#search-results > ul > li')
      .map{ |ele| ele['data-school-urn'].to_i }
  ).to eql(@schools.sort_by(&:fee).map(&:urn))
end

Given("I have searched for {string} and provided {string} for my location") do |query, location|
  path = candidates_schools_path(query: query, location: location, distance: 25)
  visit(path)

  path_with_query = [page.current_path, URI.parse(page.current_url).query].join("?")
  expect(path_with_query).to eql(path)
end

Then("the results should be sorted by distance, nearest to furthest") do
  # proximity from Bury
  urns_in_distance_order = [
    @schools.detect { |s| s.name == "Rochdale School" },
    @schools.detect { |s| s.name == "Manchester School" },
    @schools.detect { |s| s.name == "Burnley School" }
  ].map(&:urn)

  expect(
    page
      .all('#search-results > ul > li')
      .map{ |ele| ele['data-school-urn'].to_i }
  ).to eql(urns_in_distance_order)
end
