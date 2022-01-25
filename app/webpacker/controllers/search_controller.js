import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'loading']
  static values = {
    resultsId: String,
    formId: String
  }

  connect() {
    this.popstateHandler = this.handlePopstate.bind(this)
    window.addEventListener('popstate', this.popstateHandler)
  }

  disconnect() {
    window.removeEventListener('popstate', this.popstateHandler)
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
    const params = new URLSearchParams(new FormData(this.formTarget))
    const url = `${this.formAction}?${params.toString()}`

    this.executeSearch(url)

    history.pushState({}, document.title, url)
  }

  handlePopstate() {
    if (window.location.pathname === this.formAction) {
      const url = `${this.formAction}${window.location.search}`
      this.executeSearch(url)
    }
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

        document.getElementById(this.resultsIdValue).replaceWith(results)
        document.getElementById(this.formIdValue).replaceWith(form)

        this.loadingTarget.classList.remove('active')
      })
  }

  get formAction() {
    return this.formTarget.getAttribute('action')
  }
}
