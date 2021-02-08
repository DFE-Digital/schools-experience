class Schools::OnBoarding::ProfileSubject < ApplicationRecord
  belongs_to :school_profile,
    class_name: 'Schools::SchoolProfile',
    inverse_of: :profile_subjects,
    foreign_key: :schools_school_profile_id

  belongs_to :subject,
    class_name: 'Bookings::Subject',
    inverse_of: :onboarding_profile_subjects,
    foreign_key: :bookings_subject_id

  validates :school_profile, presence: true
  validates :subject, presence: true

  validates :schools_school_profile_id,
    uniqueness: { scope: %i[bookings_subject_id] }
end
