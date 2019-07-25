class Event < ApplicationRecord
  EVENT_TYPES = %w(
    school_disabled
    school_enabled
    school_edubase_data_refreshed
  ).freeze

  belongs_to :recordable,
    polymorphic: true,
    optional: true

  belongs_to :bookings_school,
    class_name: 'Bookings::School',
    foreign_key: :bookings_school_id,
    optional: true

  belongs_to :bookings_candidate,
    class_name: 'Bookings::Candidate',
    foreign_key: :bookings_candidate_id,
    optional: true

  validates :event_type, inclusion: EVENT_TYPES
  validate :ensure_school_or_candidate_present

private

  def ensure_school_or_candidate_present
    if bookings_school_id.blank? && bookings_candidate_id.blank?
      errors.add(:base, 'Either a school or bookings_candidate must be present')
    end
  end
end
