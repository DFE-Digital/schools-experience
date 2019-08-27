module CookiesHelper
  def show_cookie_message?
    cookie_name = 'seen_cookie_message'
    seen_value = 'yes'

    return false if cookies[cookie_name] == seen_value

    cookies[cookie_name] = {
      value: seen_value,
      httponly: true,
      expires: 2.weeks.from_now
    }
  end
end
