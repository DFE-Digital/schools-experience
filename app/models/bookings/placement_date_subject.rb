class Bookings::PlacementDateSubject < ApplicationRecord
  belongs_to :bookings_placement_date, class_name: 'Bookings::PlacementDate'
  belongs_to :bookings_subject, class_name: 'Bookings::Subject'

  validates :bookings_placement_date, presence: true
  validates :bookings_subject, presence: true

  validates :bookings_subject_id,
    inclusion: { in: :allowed_subject_choices },
    if: :bookings_subject_id

private

  def allowed_subject_choices
    bookings_placement_date.bookings_school.subject_ids
  end
end
