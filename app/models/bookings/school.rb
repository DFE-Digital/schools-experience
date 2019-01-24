class Bookings::School < ApplicationRecord
  include FullTextSearch
  include GeographicSearch

  validates :name,
    presence: true,
    length: { maximum: 128 }

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

  scope :that_provide, ->(subject_ids) do
    if subject_ids.present?
      joins(:subjects).merge(Bookings::Subject.where(id: subject_ids)).distinct
    else
      all
    end
  end

  scope :at_phase, ->(phase_ids) do
    if phase_ids.present?
      joins(:phases).merge(Bookings::Phase.where(id: phase_ids)).distinct
    else
      all
    end
  end

  scope :costing_upto, ->(amount) do
    if amount.present?
      where(arel_table[:fee].lteq(amount)).or(where(fee: nil))
    else
      all
    end
  end
end
