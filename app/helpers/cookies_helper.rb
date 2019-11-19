module CookiesHelper
  def show_cookie_message?
    cookie_name = 'seen_cookie_message'
    seen_value = 'yes'

    if cookies[cookie_name] == seen_value || cookies[CookiePreference.cookie_key].present?
      false
    else
      true
    end
  end
end
