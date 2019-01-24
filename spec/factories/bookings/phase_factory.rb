FactoryBot.define do
  factory :bookings_phase, class: 'Bookings::Phase' do
    sequence(:name) { |n| "phase #{n}" }
  end
end
