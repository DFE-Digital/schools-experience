import { CookiePreferences } from 'cookie_preferences'
import Cookies from 'js-cookie'

describe('CookiePreferences', () => {
  let cookiePreferences;

  const clearCookies = () => {
    Cookies.remove(global.cookie_preference_key)
  }

  beforeEach(() => {
    global.cookie_preference_key = 'cookie-preference-v1'
    global.cookie_categories = { 'analytics': ['_ga'] }

    clearCookies()

    cookiePreferences = new CookiePreferences()
  })

  describe('cookieName', () => {
    it('returns the globally configured cookie name', () => {
      expect(cookiePreferences.cookieName).toEqual(global.cookie_preference_key)
    })
  })

  describe('categories', () => {
    it('returns the globally configured cookie categories', () => {
      expect(cookiePreferences.categories).toEqual(global.cookie_categories)
    })
  })

  describe('readSettings', () => {
    describe('when the cookie is not set', () => {
      it('returns an empty object', () => {
        expect(cookiePreferences.readSettings()).toEqual({})
      })
    })

    describe('when the cookie is set', () => {
      it('returns the contents of the cookie', () => {
        const cookieValue = JSON.stringify({ some: "value" })
        Cookies.set(global.cookie_preference_key, cookieValue)
        expect(cookiePreferences.readSettings()).toEqual(JSON.parse(cookieValue))
      })
    })
  })

  describe('allowed', () => {
    beforeEach(() => {
      const cookieValue = JSON.stringify({ analytics: true, marketing: false, invasive: 'true' })
      Cookies.set(global.cookie_preference_key, cookieValue)
    })

    it('returns true if the category is allowed', () => {
      expect(CookiePreferences.allowed('analytics')).toBe(true)
    })

    it('returns false if the category is not allowed (must be explicitly true)', () => {
      expect(CookiePreferences.allowed('marketing')).toBe(false)
      expect(CookiePreferences.allowed('invasive')).toBe(false)
    })

    it('returns undefined if the category is not recognised', () => {
      expect(CookiePreferences.allowed('other')).toBe(false)
    })
  })
})
