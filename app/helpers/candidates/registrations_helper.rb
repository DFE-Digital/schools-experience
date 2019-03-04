module Candidates::RegistrationsHelper
  def summary_row(key, value, change_path = nil)
    action = change_path ? link_to('Change', change_path) : nil

    render \
      partial: "candidates/registrations/application_previews/list_row",
      locals: { key: key, value: value, action: action }
  end
end
