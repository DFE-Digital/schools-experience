module Schools::ConfirmAttendanceHelper
  def confirm_attendance_radio(builder, booking_id, value, label_text)
    content_tag('div', class: "govuk-radios__item") do
      safe_join(
        [
          builder.radio_button(booking_id, value, class: %w(govuk-radios__input)),
          builder.label("#{booking_id}_#{value}", class: %(govuk-label govuk-radios__label)) do
            label_text
          end
        ]
      )
    end
  end
end
