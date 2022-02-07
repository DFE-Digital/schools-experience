FactoryBot.define do
  factory :candidates_booking_feedback, class: "Candidates::BookingFeedback" do
    association :booking, factory: :bookings_booking

    gave_realistic_impression { false }
    covered_subject_of_interest { false }
    influenced_decision { false }
    intends_to_apply { false }
    effect_on_decision { "positively" }
  end
end
