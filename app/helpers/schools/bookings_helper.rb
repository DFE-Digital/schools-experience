module Schools::BookingsHelper
  def format_boolean(value)
    value ? "Yes" : "No"
  end
end
