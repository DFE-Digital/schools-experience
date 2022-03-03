FactoryBot.define do
  factory :candidate_parking_information, class: 'Schools::OnBoarding::CandidateParkingInformation' do
    parking_provided { true }
    parking_details { 'Plenty of spaces' }
    nearby_parking_details { nil }

    trait :without_parking do
      parking_provided { false }
      nearby_parking_details { 'Public car park across the street' }
    end
  end
end
