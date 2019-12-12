require 'rails_helper'

describe 'schools/dashboards/show.html.erb', type: :view do
  let(:school) { create(:bookings_school) }
  before { assign :current_school, school }

  before do
    allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)
  end

  context 'when the user has other schools' do
    before { assign :other_urns, [111111] }
    subject { render }

    context 'when in-app school switching is not enabled' do
      specify 'the page should have a change school link that initiates a DfE Sign-in switch' do
        expect(subject).to have_link('Change school', href: '/schools/switch/new')
      end
    end

    context 'when in-app school switching is enabled' do
      before do
        allow(Schools::ChangeSchool).to receive(:allow_school_change_in_app?).and_return(true)
      end

      subject { render }

      specify 'the page should have a change school link that initiates an internal switch' do
        expect(subject).to have_link('Change school', href: '/schools/change')
      end
    end
  end

  context 'when the user has no other schools' do
    before { assign :other_urns, [] }
    subject { render }

    specify 'the page should have no change school link' do
      expect(subject).not_to have_link('Change school')
    end
  end
end
