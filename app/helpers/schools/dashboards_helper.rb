module Schools::DashboardsHelper
  def numbered_circle(number, id: nil, colour: 'red', width: 26, height: 30, font_size: "16px", circle_size: 13)
    content_tag(:svg, id: id, width: width, height: height) do
      safe_join([
        tag(:circle, class: colour, cx: circle_size, cy: circle_size, r: circle_size),
        content_tag(:text, x: "50%", y: "50%", dy: "0.2em", "font-size" => font_size) do
          number.to_s
        end
      ])
    end
  end

  def school_enabled_description(school)
    school.enabled? ? "enabled" : "disabled"
  end

  def show_no_placement_dates_warning?(school)
    school.availability_preference_fixed? &&
      school.bookings_placement_dates.available.none?
  end

  def show_no_availability_info_warning?(school)
    !school.availability_preference_fixed? &&
      school.availability_info.nil?
  end
end
