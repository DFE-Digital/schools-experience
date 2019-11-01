FactoryBot.define do
  factory :bookings_placement_date, class: 'Bookings::PlacementDate' do
    date { 3.weeks.from_now }
    association :bookings_school, factory: :bookings_school
    published_at { DateTime.now }
    supports_subjects { true }

    trait :in_the_past do
      date { 6.weeks.ago }
      to_create { |instance| instance.save(validate: false) }
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

    trait :subject_specific do
      subject_specific { true }
    end

    trait :not_supporting_subjects do
      supports_subjects { false }
    end
  end
end
