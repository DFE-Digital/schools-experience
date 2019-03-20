require 'rails_helper'

RSpec.describe "candidates/schools/show.html.erb", type: :view do
  before do
    @school = Candidates::School.find(create(:bookings_school).urn)
    assign :school, @school

    render
  end

  it "will include the schools name" do
    link = new_candidates_school_registrations_placement_preference_path(@school)

    expect(rendered).to have_css('h1', text: @school.name)
    expect(rendered).to have_css("a.govuk-button[href=\"#{link}\"]")
  end
end
