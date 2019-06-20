When("I am on the cancel booking page") do
  path = path_for('cancel booking', booking_id: @booking_id)
  visit(path)
  expect(page.current_path).to eql(path)
end
