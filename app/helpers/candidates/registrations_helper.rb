module Candidates::RegistrationsHelper
  def summary_row(key, value, change_path = nil)
    action = change_path ? link_to('Change', change_path) : nil

    render \
      partial: "list_row", locals: { key: key, value: value, action: action }
  end
end
