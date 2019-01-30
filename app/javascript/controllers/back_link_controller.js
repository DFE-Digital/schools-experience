import { Controller } from "stimulus"

// This replaces a back link with an actual 'pop' from the users browser
// history, rather than being a forward navigation to what we think was their
// previous url
export default class extends Controller {

  connect() {
    this.element.addEventListener('click', function(ev) {
      ev.preventDefault() ;

      window.history.back(-1);

      return false;
    }) ;
  }
}
