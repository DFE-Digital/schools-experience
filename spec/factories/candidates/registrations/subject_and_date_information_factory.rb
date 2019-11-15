FactoryBot.define do
  factory :subject_and_date_information, class: Candidates::Registrations::SubjectAndDateInformation do
    bookings_placement_date_id { create(:bookings_placement_date).id }
    bookings_subject_id { nil }
  end
end
