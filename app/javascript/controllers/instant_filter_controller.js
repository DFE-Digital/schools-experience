import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    const form = this.element ;

    this.element.addEventListener('change', function(ev) {
      if (ev.target.nodeName == 'INPUT') {
          form.submit() ;
      }
    }) ;
  }
}
