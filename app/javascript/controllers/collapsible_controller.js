import { Controller } from "stimulus"

export default class extends Controller {

  toggle(ev) {
    ev.preventDefault() ;
    console.log("SHOW HIDE PANEL") ;
  }
}
