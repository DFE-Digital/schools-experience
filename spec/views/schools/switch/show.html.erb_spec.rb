require 'rails_helper'

describe 'schools/switch/show.html.erb', type: :view do
  let(:school) { create(:bookings_school) }
  before { assign :current_school, school }

  context 'when a URN param is present' do
    let(:other_school) { create(:bookings_school) }

    before { assign :school, other_school }
    before { render }

    specify 'should render the page with information about the schools' do
      expect(response).to match(school.name)
      expect(response).to match(other_school.name)
    end
  end

  context 'when no URN param is present' do
    before { assign :current_school, school }
    before { render }

    specify 'should render the page with information about the current school only' do
      expect(response).to match(school.name)
      expect(response).to match(/this placement request belongs to another school/)
    end
  end
end
