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
    validates :bookings_placement_request_id, presence: true
    validates :bookings_subject, presence: true
    validates :bookings_school, presence: true

    delegate \
      :availability,
      :degree_stage,
      :degree_stage_explaination,
      :degree_subject,
      :has_dbs_check,
      :objectives,
      :teaching_stage,
      to: :bookings_placement_request

    scope :upcoming, -> { where(arel_table[:date].between(Time.now..2.weeks.from_now)) }

    # FIXME this will eventually be handled 'higher up', probably by
    # a helper or directly in the view
    def candidate
      Bookings::Gitis::CRM.new('abc123').find(1)
    end

    def received_on
      bookings_placement_request.created_at.to_date
    end

    def status
      "New"
    end
  end
end
