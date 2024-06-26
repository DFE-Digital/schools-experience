class Bookings::Subject < ApplicationRecord
  validates :name,
    presence: true,
    length: { minimum: 2, maximum: 64 },
    uniqueness: true

  has_many :bookings_schools_subjects,
    class_name: "Bookings::SchoolsSubject",
    inverse_of: :bookings_subject,
    foreign_key: :bookings_subject_id,
    dependent: :destroy

  has_many :schools,
    class_name: "Bookings::School",
    through: :bookings_schools_subjects,
    source: :bookings_school

  has_many :placement_date_subjects,
    class_name: 'Bookings::PlacementDateSubject',
    inverse_of: :bookings_subject,
    foreign_key: :bookings_subject_id,
    dependent: :destroy

  has_many :onboarding_profile_subjects,
    class_name: 'Schools::OnBoarding::ProfileSubject',
    inverse_of: :subject,
    foreign_key: :bookings_subject_id,
    dependent: :destroy

  has_many :placement_requests,
    inverse_of: :subject,
    foreign_key: :bookings_subject_id,
    dependent: :restrict_with_exception

  default_scope -> { where.not(hidden: true) }
  scope :secondary_subjects, -> { where(secondary_subject: true).where.not(hidden: true) }

  scope :ordered_by_name, -> { order(name: 'asc') }
end
