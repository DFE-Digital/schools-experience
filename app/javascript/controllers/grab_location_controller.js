import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "latitude", "longitude", "location", "icon" ] ;
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

    const txt = document.createTextNode("Use my location ") ;
    link.appendChild(txt) ;

    const icon = document.createElement('i') ;
    icon.className = 'fa fa-fw fa-crosshairs' ;
    icon.setAttribute('data-target', this.identifier + '.icon') ;
    link.appendChild(icon) ;

    label.parentNode.insertBefore(link, label) ;

    return link ;
  }

  requestLocation(ev) {
    ev.preventDefault() ;

    this.showSpinner() ;

    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.setCoords(position.coords) ;
          this.hideSpinner()
        },
        () => {
          this.hideSpinner()
        }
      ) ;
    }
  }

  showSpinner() {
    this.iconTarget.classList.remove('fa-crosshairs') ;
    this.iconTarget.classList.add('fa-spinner') ;
    this.iconTarget.classList.add('fa-spin') ;
  }

  hideSpinner() {
    this.iconTarget.classList.remove('fa-spin') ;
    this.iconTarget.classList.remove('fa-spinner') ;
    this.iconTarget.classList.add('fa-crosshairs') ;
  }
}
