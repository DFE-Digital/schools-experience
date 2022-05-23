# When a school converts to an academy they appear as
# a new school (with separate URN) in School Experience.
# Occasionally we get requests to migrate placement requests
# from the original school to the new academy account - this aims
# to make that process automated.
#
# The transfer is very limited at the moment; it attempts to handle
# new placement requests only and match subject specific/placement dates.
#
# You are expected to pull the production database and test the transfer
# locally prior to running it in production (or risk data integrity issues)!
# If we find this request becomes frequent we can expand the logic
# to be more robust/safer.
class PlacementRequestTransfer
  class TransferError < RuntimeError; end

  def initialize(placement_request_id, school_id)
    @placement_request_id = placement_request_id
    @school_id = school_id
  end

  def transfer!
    verify!

    placement_request.school = school
    placement_request.subject = matching_subject
    placement_request.placement_date = matching_fixed_placement_date
    placement_request.save!
  end

private

  def verify!
    raise TransferError, "you cannot transfer a booked placement request" if booked?
    raise TransferError, "you cannot transfer a placement request with a '#{status}' status" unless new_or_viewed?

    verify_subject!
    verify_subject_first_choice!
    verify_fixed_placement_date!
    verify_flexible_placement_date!
    verify_experience_type!
  end

  def verify_subject!
    return unless subject_specific?

    raise TransferError, "could not match subject '#{subject_name}' in school" if matching_subject.nil?
  end

  def verify_subject_first_choice!
    raise TransferError, "school does not support subject '#{placement_request.subject_first_choice}'" if matching_subject_first_choice.nil?
  end

  def verify_fixed_placement_date!
    return unless fixed_placement_date?

    raise TransferError, "school does not support fixed placement dates" unless school.availability_preference_fixed?
    raise TransferError, "could not match fixed placement date '#{fixed_placement_date}' in school" if matching_fixed_placement_date.nil?
  end

  def verify_flexible_placement_date!
    return if fixed_placement_date?

    raise TransferError, "school does not support flexible placement dates" if school.availability_preference_fixed?
  end

  def verify_experience_type!
    return if school.experience_type == "both"

    unless school.experience_type == placement_request.school.experience_type
      raise TransferError, "school does not support #{placement_request.school.experience_type} experience type"
    end
  end

  def matching_subject_first_choice
    school_subjects.find { |subject| subject == placement_request.subject_first_choice }
  end

  def school_subjects
    if school.subjects.any?
      school.subjects.pluck(:name)
    else
      Candidates::School.subjects.map(&:last)
    end
  end

  def matching_subject
    school.subjects.find_by(name: subject_name)
  end

  def subject_name
    placement_request.subject&.name
  end

  def status
    placement_request.status
  end

  def new_or_viewed?
    status.in?(%w[New Viewed])
  end

  def fixed_placement_date
    placement_request.placement_date&.date
  end

  def booked?
    placement_request.booking.present?
  end

  def subject_specific?
    placement_request.subject.present?
  end

  def fixed_placement_date?
    fixed_placement_date.present?
  end

  def matching_fixed_placement_date
    school.bookings_placement_dates.find_by(date: fixed_placement_date)
  end

  def placement_request
    @placement_request ||= Bookings::PlacementRequest.find(@placement_request_id)
  end

  def school
    @school ||= Bookings::School.find(@school_id)
  end
end
