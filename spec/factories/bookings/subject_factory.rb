FactoryBot.define do
  factory :bookings_subject, class: 'Bookings::Subject' do
    sequence(:name) { |n| "subject #{n}" }
  end
end
