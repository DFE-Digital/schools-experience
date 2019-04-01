class Schools::OnBoarding::PhaseSubject < ApplicationRecord
  belongs_to :schools_school_profile,
    class_name: 'Schools::SchoolProfile',
    foreign_key: :schools_school_profile_id

  belongs_to :phase,
    class_name: 'Bookings::Phase',
    foreign_key: :bookings_phase_id

  belongs_to :subject,
    class_name: 'Bookings::Subject',
    foreign_key: :bookings_subject_id

  validates :schools_school_profile, presence: true
  validates :subject, presence: true
  validates :phase, presence: true

  validates :schools_school_profile_id,
    uniqueness: { scope: %i(bookings_subject_id bookings_phase_id) }

  # NOTE can't use a join here as it breaks the scope when used by the has_many
  # through association on school_profile.
  scope :at_phase, ->(bookings_phase) do
    where bookings_phase_id: bookings_phase.id
  end
end
