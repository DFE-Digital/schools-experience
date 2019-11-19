module CookiesHelper
  def show_cookie_message?
    if cookies[CookiePreference.cookie_key].present?
      false
    else
      true
    end
  end
end
