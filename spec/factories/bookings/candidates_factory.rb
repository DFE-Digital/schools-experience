FactoryBot.define do
  factory :candidate, class: 'Bookings::Candidate' do
    gitis_uuid { SecureRandom.uuid }
  end
end
