require 'rails_helper'

RSpec.describe "candidates/schools/show.html.erb", type: :view do
  let(:demo_school) do
    OpenStruct.new YAML.load_file('demo-school.yml')
  end

  before do
    assign :school, demo_school
    render
  end

  it "will include the schools name" do
    link = candidates_school_registrations_placement_preference_path(demo_school.urn)

    expect(rendered).to have_css('h1', text: demo_school.name)
    expect(rendered).to have_css("a.govuk-button[href=\"#{link}\"]")
  end
end
