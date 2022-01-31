import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'loading', 'submit', 'tag']
  static values = {
    resultsId: String,
    formId: String
  }

  connect() {
    if (this.supported) {
      this.updateInterface()
    }
  }

  removeTag(e) {
    e.preventDefault()

    const button = e.target
    const { key, value } = button.dataset
    const formElement = document.getElementById(`${key}-${value}-field`)

    this.clearFormElement(formElement)
    this.removeTagElement(button)
    this.performSearch()
  }

  clearFormElement(element) {
    const type = (element || {}).type

    switch(type) {
      case 'checkbox':
        element.checked = false
        break
      default:
        throw `Unsupported element type: ${type}`
    }
  }

  removeTagElement(button) {
    const tag = button.closest('.facet-tags__wrapper')
    const group = tag.closest('.facet-tags__group')
    const tagCount = group.querySelectorAll('.facet-tags__wrapper').length

    if (tagCount === 1) {
      group.remove()
    } else {
      tag.remove()

      const firstPreposition = group.querySelector('.facet-tags__wrapper .facet-tags__preposition')
      firstPreposition.textContent = null
    }
  }

  performSearch() {
    if (!this.supported) {
      return
    }

    const params = new URLSearchParams(new FormData(this.formTarget))
    const url = `${this.formAction}?${params.toString()}`

    this.executeSearch(url)

    history.replaceState({}, document.title, url)

    this.sendPageView(url)
  }

  executeSearch(url) {
    this.loadingTarget.classList.add('active')

    fetch(url)
      .then(response => response.text())
      .then(text => {
        const parser = new DOMParser()
        const response = parser.parseFromString(text, 'text/html')
        const results = response.getElementById(this.resultsIdValue)
        const form = response.getElementById(this.formIdValue)

        document.getElementById(this.resultsIdValue).innerHTML = results.innerHTML
        document.getElementById(this.formIdValue).innerHTML = form.innerHTML

        this.updateInterface()

        this.loadingTarget.classList.remove('active')
      })
  }

  sendPageView(url) {
    if (window.gtag) {
      window.gtag('set', 'page_path', url);
      window.gtag('event', 'page_view');
    }
  }

  updateInterface() {
    this.submitTarget.classList.add('hidden')
    this.tagTargets.forEach(tag => tag.classList.add('interactive'))
  }

  get formAction() {
    return this.formTarget.getAttribute('action')
  }

  get supported() {
    return 'URLSearchParams' in window && 'fetch' in window && 'closest' in Element.prototype
  }
}
