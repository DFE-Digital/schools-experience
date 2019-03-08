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
  visit(candidates_schools_path)
  fill_in "Find what?", with: query
  fill_in "Where?", with: location
  select "25", from: "Distance"
  click_button "Find"
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

Then("the results should be sorted by relevance, highest to lowest") do
  urns_in_relevance_order = [
    @schools.detect { |s| s.name == "Manton School" },
    @schools.detect { |s| s.name == "Mansfield School" },
    @schools.detect { |s| s.name == "Manningtree Primary School" }
  ].map(&:urn)

  expect(
    page
      .all('#search-results > ul > li')
      .map{ |ele| ele['data-school-urn'].to_i }
  ).to eql(urns_in_relevance_order)
end
