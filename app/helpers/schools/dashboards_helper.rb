module Schools::DashboardsHelper
  def not_onboarded_warning(school)
    if school.placement_requests.any?
      "You have school experience requests waiting"
    else
      "Your profile is not complete"
    end
  end

  def numbered_circle(number, aria_label:, id: nil, show_if_zero: false)
    # Does string comparison in case its not a number
    return if number.nil?
    return if number.to_s == '0' && !show_if_zero

    tag.div(class: 'alert-counter') do
      tag.div(class: 'numbered-circle-container') do
        tag.div(id: id, class: 'numbered-circle', aria: { label: "#{number} #{aria_label}" }) do
          tag.div(number, class: 'number')
        end
      end
    end
  end

  def school_enabled_description(school)
    school.enabled? ? "on" : "off"
  end

  def show_no_placement_dates_warning?(school)
    school.availability_preference_fixed? &&
      school.bookings_placement_dates.available.none?
  end

  def show_no_availability_info_warning?(school)
    !school.availability_preference_fixed? &&
      school.availability_info.blank?
  end

  def status_column_size(status)
    {
      disabled: 'govuk-grid-column-one-third',
      enabled_without_dates: 'govuk-grid-column-two-thirds',
      enabled_without_availability: 'govuk-grid-column-two-thirds',
    }[status]
  end
end
