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
      phases: Bookings::Phase.where(name: attributes["Phase"]),
      coordinates: locate(attributes["Location"])
    )
  end

  onboard_schools(@schools)

  expect(Bookings::School.count).to eql(table.rows.length)
end

When("I have provided {string} as my location") do |location|
  path = candidates_schools_path(location: Encryptor.encrypt(location), distance: 25)
  visit(path)
  path_with_query = [page.current_path, URI.parse(page.current_url).query].join("?")
  expect(path_with_query).to eql(path)
end

Given("I have provided a point in {string} as my location") do |centre|
  points = {
    "Bury" => {
      "latitude" => 53.593,
      "longitude" => -2.289
    }
  }

  point = points[centre]
  raise "No point found for #{centre}" if point.blank?

  path = candidates_schools_path(latitude: point["latitude"], longitude: point["longitude"], distance: 25)
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
      .map { |ele| ele['data-school-urn'].to_i }
  ).to eql(urns_in_distance_order)
end
