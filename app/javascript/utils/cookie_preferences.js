import Cookies from 'js-cookie'

export class CookiePreferences {
  settings = null

  constructor() {
    this.settings = this.readSettings()
  }

  get categories() {
    return window.cookie_categories
  }

  get cookieName() {
    return window.cookie_preference_key
  }

  readSettings() {
    const cookie = Cookies.get(this.cookieName)

    if (typeof(cookie) == 'undefined' || !cookie) {
      return {}
    }

    return JSON.parse(cookie)
  }

  allowed(category) {
    return this.settings[category] === true
  }

  static allowed(category) {
    return (new CookiePreferences).allowed(category)
  }
}
