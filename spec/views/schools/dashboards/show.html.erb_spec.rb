require 'rails_helper'

describe 'schools/dashboards/show.html.erb', type: :view do
  let(:school) { create(:bookings_school) }
  before { assign :current_school, school }

  before do
    allow(Schools::DFESignInAPI::Client).to receive(:enabled?).and_return(true)
  end

  context 'when the user has other schools' do
    before { assign :other_urns, [111111] }
    before { render }

    specify 'the page should have a change school link' do
      expect(rendered).to have_link('Change school')
    end
  end

  context 'when the user has no other schools' do
    before { assign :other_urns, [] }
    before { render }

    specify 'the page should have no change school link' do
      expect(rendered).not_to have_link('Change school')
    end
  end
end
