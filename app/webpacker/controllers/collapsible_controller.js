import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  toggle(ev) {
    ev.preventDefault() ;
    this.element.classList.toggle('show') ;
  }
}
