FactoryBot.define do
  factory :bookings_placement_date, class: 'Bookings::PlacementDate' do
    date { 3.weeks.from_now }
    association :bookings_school, factory: :bookings_school
    published_at { DateTime.now }
    supports_subjects { true }
    capped { false }

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

    trait :capped do
      capped { true }
      max_bookings_count { 3 }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :per_subject_capped do
      transient do
        max_bookings_per_subject { 3 }
      end

      association :bookings_school, factory: %i(bookings_school with_subjects)
      capped { true }
      max_bookings_count { nil }
      supports_subjects { true }
      subject_specific { true }

      after :build do |date, evaluator|
        date.placement_date_subjects.build \
          bookings_subject_id: date.bookings_school.subject_ids[0],
          max_bookings_count: evaluator.max_bookings_per_subject
      end
    end
  end
end
