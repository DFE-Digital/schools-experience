require 'rails_helper'

describe 'schools/change_schools/show.html.erb', type: :view do
  before { allow(Rails.application.config.x).to receive(:dfe_sign_in_api_enabled).and_return(true) }

  let(:school) { create(:bookings_school) }
  let(:other_schools) { create_list(:bookings_school, 3) }
  let(:all_schools) { other_schools.push(school).compact }
  let(:urns) { other_schools.map(&:urn) }

  before do
    allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)
    allow_any_instance_of(Schools::DFESignInAPI::Organisations).to receive(:urns).and_return(urns)
  end

  context 'when the user has access to multiple schools' do
    before { allow(Rails.application.config.x).to receive(:dfe_sign_in_api_school_change_enabled).and_return(true) }

    before do
      assign :current_school, school
      assign :schools, all_schools
      assign :change_school, Schools::ChangeSchool.new(nil, {}, urn: school&.urn)
      without_partial_double_verification do
        allow(view).to receive(:current_urn).and_return school&.urn
      end
    end

    before { render }

    specify 'there should be one radio button per school' do
      expect(rendered).to have_css("input[type='radio']", count: all_schools.size)
    end

    specify 'the current school should already be selected' do
      expect(rendered).to have_css(
        "input[type='radio'][value='%<school_urn>d'][checked='checked']" % {
          school_urn: school.urn
        }
      )
    end

    context 'no existing school chosen' do
      let(:school) { nil }

      specify 'there should be one radio button per school' do
        expect(rendered).to have_css("input[type='radio']", count: all_schools.size)
      end

      specify 'the no school should be selected' do
        expect(rendered).not_to \
          have_css "input[type='radio'][checked='checked']"
      end
    end
  end

  context 'when the user only has access to one school' do
    # should we do something extra here? the form will render with a single
    # already-selected radio button
  end

  context 'when in app school-changing is disabled' do
    before { allow(Rails.application.config.x).to(receive(:dfe_sign_in_api_school_change_enabled)).and_return(false) }

    before { render }

    specify 'should inform the user that changing is disabled' do
      expect(rendered).to match(/Changing school is not enabled/)
    end
  end
end
