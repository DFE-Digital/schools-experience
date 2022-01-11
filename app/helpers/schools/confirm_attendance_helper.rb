module Schools::ConfirmAttendanceHelper
  # NOTE: we can't use the form builder here because it wraps everything in
  # form-groups and fieldsets which affect how it's displayed in a table cell
  def confirm_attendance_radio(builder, booking_id, value, label_text)
    builder.govuk_radio_button(booking_id.to_s, value, class: %w[govuk-radios__input], label: { text: label_text })
  end
end
