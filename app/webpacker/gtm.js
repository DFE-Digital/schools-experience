import { CookiePreferences } from 'cookie_preferences'

export default class Gtm {
  constructor(id, nonce) {
    this.id = id
    this.nonce = nonce
  }

  init() {
    this.initWindow()
    this.sendDefaultConsent()
    this.initContainer()
  }

  initWindow() {
    window.dataLayer = window.dataLayer || []

    function gtag() {
      window.dataLayer.push(arguments)
    }

    window.gtag = window.gtag || gtag
  }

  initContainer() {
    (function(w, d, s, l, i, n) {
      w[l] = w[l] || []
      w[l].push({
          'gtm.start': new Date().getTime(),
          event: 'gtm.js'
      })
      var f = d.getElementsByTagName(s)[0],
          j = d.createElement(s),
          dl = l != 'dataLayer' ? '&l=' + l : ''
      j.async = true
      j.src = 'https://www.googletagmanager.com/gtm.js?id=' + i + dl
      n && j.setAttribute('nonce', n)
      f.parentNode.insertBefore(j, f)
    })(window, document, 'script', 'dataLayer', this.id, this.nonce)
  }

  sendDefaultConsent() {
    window.gtag('consent', 'default', this.consent())
  }

  consent() {
    return {
      analytics_storage: this.consentValue('analytics'),
    }
  }

  consentValue(category) {
    return CookiePreferences.allowed(category) ? 'granted' : 'denied'
  }
}
