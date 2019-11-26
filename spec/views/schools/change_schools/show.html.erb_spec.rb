require 'rails_helper'

describe 'schools/change_schools/show.html.erb', type: :view do
  let(:school) { create(:bookings_school) }
  let(:other_schools) { create_list(:bookings_school, 3) }
  let(:all_schools) { other_schools.push(school) }
  let(:urns) { other_schools.map(&:urn) }

  before do
    allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)
    allow_any_instance_of(Schools::DFESignInAPI::Organisations).to receive(:urns).and_return(urns)
  end

  context 'when the user has access to multiple schools' do
    before do
      assign :current_school, school
      assign :schools, all_schools
      assign :change_school, Schools::ChangeSchool.new(id: school.id)
    end

    before { render }

    specify 'there should be one check box per school' do
      expect(rendered).to have_css("input[type='radio']", count: all_schools.size)
    end

    specify 'the current school should already be selected' do
      expect(rendered).to have_css(
        "input[type='radio'][value='%<school_id>d'][checked='checked']" % {
          school_id: school.id
        }
      )
    end
  end

  context 'when the user only has access to one school' do
    # show them an error message or something
  end
end
