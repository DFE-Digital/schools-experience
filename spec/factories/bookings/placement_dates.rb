FactoryBot.define do
  factory :bookings_placement_date, class: 'Bookings::PlacementDate' do
    date { 3.weeks.from_now }
    association :bookings_school, :with_fixed_availability_preference, factory: :bookings_school
    published_at { DateTime.now }
    supports_subjects { true }
    virtual { false }

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

    trait :virtual do
      virtual { true }
    end

    trait :subject_specific do
      subject_specific { true }
    end

    trait :not_supporting_subjects do
      supports_subjects { false }
    end
  end
end
