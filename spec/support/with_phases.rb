shared_context 'with phases' do
  before do
    FactoryBot.create :bookings_phase, :early_years
    FactoryBot.create :bookings_phase, :primary
    FactoryBot.create :bookings_phase, :secondary
    FactoryBot.create :bookings_phase, :college
  end
end
