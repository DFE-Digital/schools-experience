import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ 'submitButton' ]

  connect() {
    window.addEventListener( "pageshow", ( event ) => {
      this.enableSubmitButton()
    });
  }

  enableSubmitButton() {
    this.submitButtonTarget.disabled = false;
  }

  disableSubmitButton() {
    this.submitButtonTarget.disabled = true;
  };
}
