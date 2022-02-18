class Bookings::PlacementRequest::Transfer
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :placement_request, :uuids_to_urns

  attribute :transfer_to_urn, :integer
  validates :transfer_to_urn, inclusion: { in: :organisation_urns }

  def initialize(placement_request, role_checked_uuids_to_urns, attributes = {})
    @placement_request = placement_request
    @uuids_to_urns = role_checked_uuids_to_urns

    super attributes
  end

  def available_schools
    # TODO: filter to those with applicable dates/subjects etc?
    Bookings::School.includes([:available_placement_dates]).ordered_by_name.where(urn: organisation_urns).reject do |school|
      school.availability_preference_fixed? && school.available_placement_dates.empty?
    end
  end

  def perform!
    return false unless valid?

    school = transfer_to_school
    new_request = placement_request.dup.tap do |request|
      request.school = school
      request.subject = nil
      if school.availability_preference_fixed?
        request.placement_date = school.available_placement_dates.sample
      else
        request.availability = "my availability" # put in placement date.to_s here?
      end
      request.viewed_at = nil
      request.token = nil
      request.subject_first_choice = school.subjects.first.name
      request.subject_second_choice = "I don't have a second subject"#school.subjects.last.name
      # TODO: include reference to where it was transferred from?

      # NOTE: instead of dup the record we could pre-fill the booking flow
      # and have the school user go through it on the users' behalf?

      # request.experience_type = nil
    end

    new_request.save!

    placement_request.destroy # Or mark as transferred?

    true
  end

  def transfer_to_school
    Bookings::School.find_by(urn: transfer_to_urn)
  end

private

  def organisation_urns
    uuids_to_urns.values.excluding(placement_request.school_urn)
  end
end
