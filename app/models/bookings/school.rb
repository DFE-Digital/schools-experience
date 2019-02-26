class Bookings::School < ApplicationRecord
  include FullTextSearch
  include GeographicSearch

  validates :name,
    presence: true,
    length: { maximum: 128 }

  validates :fee,
    presence: true,
    numericality: { greater_than_or_equal_to: 0, only_integer: true }

  has_many :bookings_schools_subjects,
    class_name: "Bookings::SchoolsSubject",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id

  has_many :subjects,
    class_name: "Bookings::Subject",
    through: :bookings_schools_subjects,
    source: :bookings_subject

  has_many :bookings_schools_phases,
    class_name: "Bookings::SchoolsPhase",
    inverse_of: :bookings_school,
    foreign_key: :bookings_school_id

  has_many :phases,
    class_name: "Bookings::Phase",
    through: :bookings_schools_phases,
    source: :bookings_phase

  belongs_to :school_type,
    class_name: "Bookings::SchoolType",
    foreign_key: :bookings_school_type_id

  scope :that_provide, ->(subject_ids) do
    if subject_ids.present?
      joins(:subjects).where(bookings_subjects: { id: subject_ids })
    else
      all
    end
  end

  scope :at_phases, ->(phase_ids) do
    if phase_ids.present?
      joins(:phases).where(bookings_phases: { id: phase_ids })
    else
      all
    end
  end

  scope :costing_upto, ->(limit) do
    if limit.present?
      where(arel_table[:fee].lteq(limit))
    else
      all
    end
  end

  def to_param
    urn.to_s.presence
  end

  def contact_email
    # TODO
    'CONTACT_EMAIL'
  end
end
