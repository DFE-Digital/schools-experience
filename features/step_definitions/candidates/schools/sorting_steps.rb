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

Then("the results should be sorted by distance, nearest to furthest") do
  pending "sorting not yet implemented"
  # should be ol, results will always be ordered by something?
  # below is pseudocode
  within('ul#results') do
    actual = page.all('li.school-result .name').map(&:text).map(&:name)
    expected = Bookings::School.close_to(@point, radius: 20).reorder('distance asc')
    expect(expected).to eql(actual)
  end
end

Then("the results should be sorted by fee, lowest to highest") do
  expect(
    page
      .all('#search-results > ul > li')
      .map{ |ele| ele['data-school-urn'].to_i }
  ).to eql(@schools.sort_by(&:fee).map(&:urn))
end
