module Schools::BookingsHelper
  def format_boolean(value)
    value ? "Yes" : "No"
  end

  def format_has_dbs_certificate(has_dbs_certificate)
    if has_dbs_certificate
      'Yes - Candidate says they have DBS certificate (not verified by DfE)'
    else
      'No'
    end
  end

  def attendance_status(booking)
    case booking.attended
    when true
      tag.strong 'Yes', class: 'govuk-tag'
    when false
      tag.strong 'No', class: 'govuk-tag govuk-tag--grey'
    when nil
      if booking.cancelled?
        tag.strong 'Cancelled', class: 'govuk-tag govuk-tag--red'
      else
        tag.strong 'Not set', class: 'govuk-tag govuk-tag--light-blue'
      end
    end
  end

  def descriptive_attendance_status(record)
    case record.attended
    when true
      'Attended'
    when false
      'Did not attend'
    end
  end
end
