import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "latitude", "longitude", "location", "icon" ] ;
  currentLocationString = 'Using your current location' ;
  crossHairsIcon = 'fa-crosshairs' ;
  spinnerIcon = 'fa-refresh' ;
  spinIcon = 'fa-spin' ;
  timedOut = false ;
  locationSearchFinished = false ;
  timeOutLengthSeconds = 10 ;

  connect() {
    if (this.enableGeolocation()) {
      this.addLocationLink() ;
      this.toggleCoordsState() ;
    }
  }

  isIE() {
    return (!!window.MSInputMethodContext && !!document.documentMode) ;
  }

  enableGeolocation() {
    return (("geolocation" in navigator) && !this.isIE()) ;
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
    this.toggleCoordsState() ;
  }

  setCoords(coords) {
    this.latitudeTarget.value = coords.latitude ;
    this.longitudeTarget.value = coords.longitude ;
    this.toggleCoordsState() ;
  }

  addLocationLink(el) {
    const inputId = this.locationTarget.getAttribute('id') ;
    const label = this.element.querySelectorAll('label[for="' + inputId + '"]')[0] ;

    if (!label)
      return ;

    const link = document.createElement('a') ;
    link.className = 'school-search-form__coords-request' ;
    link.setAttribute('href', '#') ;
    link.setAttribute('data-action', 'click->' + this.identifier + '#requestLocation') ;

    const txt = document.createTextNode("Use my location ") ;
    link.appendChild(txt) ;

    const icon = document.createElement('i') ;
    icon.className = 'fa fa-fw ' + this.crossHairsIcon ;
    icon.setAttribute('data-target', this.identifier + '.icon') ;
    link.appendChild(icon) ;

    label.parentNode.insertBefore(link, label) ;

    return link ;
  }

  toggleCoordsState() {
    if (this.latitudeTarget.value != '' && this.longitudeTarget.value != '') {
      this.locationTarget.value = this.currentLocationString ;
      this.element.classList.add('school-search-form__location-field--using-coords') ;
    } else {
      this.latitudeTarget.value = '' ;
      this.longitudeTarget.value = '' ;

      if (this.locationTarget.value == this.currentLocationString) {
        this.locationTarget.value = '' ;
      }

      this.element.classList.remove('school-search-form__location-field--using-coords') ;
    }
  }

  requestLocation(ev) {
    ev.preventDefault() ;

    this.showSpinner() ;
    this.startTimeout() ;

    if (this.enableGeolocation()) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          if (!this.timedOut) {
            this.locationSearchFinished = true ;
            this.setCoords(position.coords) ;
            this.hideSpinner() ;
          }
        },
        (err) => {
          this.locationSearchFinished = true ;
          this.locationUnavailable() ;
        }
      ) ;
    }
  }

  startTimeout() {
    this.timedOut = false ;
    this.locationSearchFinished = false ;
    let that = this ;

    setTimeout(function() {
      if (!that.locationSearchFinished) {
        that.timedOut = true ;
        that.locationUnavailable("Location retrieval took too long") ;
      }
    }, this.timeOutLengthSeconds * 1000) ;
  }

  locationUnavailable(msg) {
    this.hideSpinner() ;
    window.alert(msg || "Your location is not available") ;
  }

  showSpinner() {
    this.iconTarget.classList.remove(this.crossHairsIcon) ;
    this.iconTarget.classList.add(this.spinnerIcon) ;
    this.iconTarget.classList.add(this.spinIcon) ;
  }

  hideSpinner() {
    this.iconTarget.classList.remove(this.spinIcon) ;
    this.iconTarget.classList.remove(this.spinnerIcon) ;
    this.iconTarget.classList.add(this.crossHairsIcon) ;
  }
}
