const Cookies = require('js-cookie') ;

export class CookiePreferences {
  settings = null ;

  constructor() {
    this.settings = this.readSettings() ;
  }

  get categories() {
    return global.cookie_categories ;
  }

  get cookieName() {
    return global.cookie_preference_key ;
  }

  readSettings() {
    const cookie = Cookies.get(this.cookieName);
    if (typeof(cookie) == 'undefined' || !cookie)
      return false ;

    return JSON.parse(cookie) ;
  }

  allowed(category) {
    return this.settings[category] !== false ;
  }

  static allowed(category) {
    return (new CookiePreferences).allowed(category)
  }
}
