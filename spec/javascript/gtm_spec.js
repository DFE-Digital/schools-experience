import Gtm from 'gtm'
import Cookies from 'js-cookie'

describe('Google Tag Manager', () => {
  const mockGtag = () => {
    window.gtag = jest.fn()
  }

  const clearCookies = () => {
    Cookies.remove(global.cookie_preference_key)
  }

  const setupHtml = () => {
    document.body.innerHTML = '<script></script>'
  }

  const run = () => {
    const gtm = new Gtm('ABC-123', 'nonce-value')
    gtm.init()
  }

  beforeEach(() => {
    global.cookie_preference_key = 'cookie-preference-v1'
    global.cookie_categories = { 'analytics': ['_ga'] }

    clearCookies()
    setupHtml()
  })

  describe('initialisation', () => {
    beforeEach(() => {
      run()
    })

    it('defines window.dataLayer', () => {
      expect(window.gtag).toBeDefined()
    })

    it('defines window.gtag', () => {
      expect(window.dataLayer).toBeDefined()
    })

    it('appends the GTM script', () => {
      const scriptTag = document.querySelector(
        "script[src^='https://www.googletagmanager.com/gtm.js?id=ABC-123']"
      )
      expect(scriptTag).not.toBeNull()
      expect(scriptTag.getAttribute('nonce')).toEqual('nonce-value')
    })
  })

  describe('when cookies have not yet been accepted', () => {
    beforeEach(() => {
      mockGtag()
      run()
    })

    it('sends GTM defaults with all cookies denied', () => {
      expect(window.gtag).toHaveBeenCalledWith('consent', 'default', {
        analytics_storage: 'denied',
      })
    })
  })

  describe('when cookies have been accepted', () => {
    beforeEach(() => {
      Cookies.set(global.cookie_preference_key, JSON.stringify({ analytics: true }))
      mockGtag()
      run()
    })

    it('sends GTM defaults with all cookie preferences', () => {
      expect(window.gtag).toHaveBeenCalledWith('consent', 'default', {
        analytics_storage: 'granted'
      })
    })
  })
})
