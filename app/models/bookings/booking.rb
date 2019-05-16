module Bookings
  class Booking < ApplicationRecord
    belongs_to :bookings_placement_request,
      class_name: 'Bookings::PlacementRequest',
      dependent: :destroy

    belongs_to :bookings_subject,
      class_name: 'Bookings::Subject',
      dependent: :destroy

    belongs_to :bookings_school,
      class_name: 'Bookings::School',
      dependent: :destroy

    validates :date, presence: true
    validates :bookings_placement_request, presence: true
    validates :bookings_subject, presence: true
    validates :bookings_school, presence: true

    delegate \
      :objectives,
      :degree_stage,
      :degree_stage_explaination,
      :degree_subject,
      :has_dbs_check,
      :availability,
      to: :bookings_placement_request
  end
end
