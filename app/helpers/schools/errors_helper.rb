module Schools::ErrorsHelper
  def school_descriptor
    session[:school_name] || 'Your school'
  end
end
