import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "latitude", "longitude", "location" ] ;
  currentLocationString = 'Using your current location' ;

  connect() {
    if ("geolocation" in navigator) {
      for(var input of this.locationTargets) {
        this.addLocationLink(input.getAttribute('id')) ;
      }
    }
  }

  clearLocationInfo() {
    if (this.latitudeTarget.value != '' || this.longitudeTarget != '' ||
      this.longitudeTarget.value == this.currentLocationString) {
        this.removeCoords() ;
    }
  }

  removeCoords() {
    this.latitudeTarget.value = '' ;
    this.longitudeTarget.value = '' ;
    this.locationTarget.value = '' ;
    this.element.classList.remove('school-search-form__location-field--using-coords') ;
  }

  setCoords(coords) {
    this.latitudeTarget.value = coords.latitude ;
    this.longitudeTarget.value = coords.longitude ;
    this.locationTarget.value = this.currentLocationString ;
    this.element.classList.add('school-search-form__location-field--using-coords') ;
  }

  addLocationLink(input_id) {
    const label = this.element.querySelectorAll('label[for="' + input_id + '"]')[0] ;

    if (!label)
      return ;

    const link = document.createElement('a') ;
    link.className = 'school-search-form__coords-request' ;
    link.setAttribute('href', '#') ;
    link.setAttribute('data-action', 'click->' + this.identifier + '#requestLocation') ;

    const txt = document.createTextNode("Use my location") ;
    link.appendChild(txt) ;

    label.parentNode.insertBefore(link, label) ;

    return link ;
  }

  requestLocation(ev) {
    ev.preventDefault() ;

    // FIXME Show a spinner

    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          // FIXME Hide spinner
          this.setCoords(position.coords) ;
        },
        () => {
          // FIXME Hide spinner
        }
      ) ;
    }
  }
}
