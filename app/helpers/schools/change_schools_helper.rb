module Schools::ChangeSchoolsHelper
  def allow_school_change_in_app?
    [
      Rails.configuration.x.dfe_sign_in_api_enabled,
      Rails.configuration.x.dfe_sign_in_api_school_change_enabled
    ].all?
  end
end
