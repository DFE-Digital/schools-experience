require 'rails_helper'

describe 'schools/dashboards/show.html.erb', type: :view do
  let(:school) { create(:bookings_school) }
  before { assign :current_school, school }

  context 'when the user has other schools' do
    before do
      without_partial_double_verification do
        allow(view).to receive(:has_other_schools?).and_return true
      end
    end

    subject { render }

    specify 'the page should have a change school link that initiates a DfE Sign-in switch' do
      expect(subject).to have_link('Change school', href: '/schools/switch/new')
    end
  end

  context 'when the user has no other schools' do
    before do
      without_partial_double_verification do
        allow(view).to receive(:has_other_schools?).and_return false
      end
    end

    subject { render }

    specify 'the page should have no change school link' do
      expect(subject).not_to have_link('Change school')
    end
  end
end
