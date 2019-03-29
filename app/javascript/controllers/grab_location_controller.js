import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [
    "latitude", "longitude", "location", "icon", "container", "message"
  ] ;
  currentLocationString = 'Using your current location' ;
  defaultWidgetClassName = 'school-search-form__location-field' ;
  crossHairsIcon = 'fa-crosshairs' ;
  spinnerIcon = 'fa-refresh' ;
  spinIcon = 'fa-spin' ;
  timedOut = false ;
  locationSearchFinished = false ;
  timeOutLengthSeconds = 60 ;

  connect() {
    if (this.enableGeolocation()) {
      this.addLocationLink() ;
      this.addInputFieldWrapper() ;
      this.createOverlayMsg() ;
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
    if (this.latitudeTarget.value != '' || this.longitudeTarget != '') {
      this.clearOverlayMsg() ;
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

  addLocationLink() {
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

  addInputFieldWrapper() {
    const container = document.createElement('div') ;
    container.className = 'grab-location__container' ;
    container.setAttribute('data-target', 'grab-location.container') ;

    this.locationTarget.parentNode.appendChild(container) ;
    container.appendChild(this.locationTarget) ;
  }

  toggleCoordsState() {
    if (this.latitudeTarget.value != '' && this.longitudeTarget.value != '') {
      this.showLocationMsg(this.currentLocationString) ;
    } else {
      this.clearOverlayMsg() ;
    }
  }

  clearCoordsState() {
    this.latitudeTarget.value = '' ;
    this.longitudeTarget.value = '' ;
  }

  requestLocation(ev) {
    ev.preventDefault() ;

    this.showSpinner() ;
    this.startTimeout() ;
    this.clearOverlayMsg() ;

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
          this.hideSpinner() ;
        }
      ) ;
    }
  }

  startTimeout() {
    this.timedOut = false ;
    this.locationSearchFinished = false ;

    setTimeout(() => {
      if (!this.locationSearchFinished) {
        this.timedOut = true ;
        this.locationUnavailable("Location retrieval took too long") ;
      }
    }, this.timeOutLengthSeconds * 1000) ;
  }

  locationUnavailable(msg) {
    this.hideSpinner() ;
    this.showErrorMsg(msg || "Your location is not available") ;
  }

  createOverlayMsg(msg) {
    const overlayMessage = document.createElement('div') ;
    overlayMessage.setAttribute('class', 'grab-location__overlay-message') ;
    overlayMessage.setAttribute('data-action', 'click->grab-location#clearOverlayMsg') ;
    overlayMessage.setAttribute('data-target', 'grab-location.message') ;
    this.locationTarget.parentNode.appendChild(overlayMessage) ;
  }

  showErrorMsg(msg) {
    this.element.classList.add('school-search-form__location-field--error')
    this.messageTarget.innerHTML = msg ;
  }

  showLocationMsg(msg) {
    this.element.classList.add('school-search-form__location-field--using-coords') ;
    this.messageTarget.innerHTML = msg ;
  }

  clearOverlayMsg() {
    if (this.messageTarget)
      this.messageTarget.innerHTML = '' ;

    this.element.className = this.defaultWidgetClassName ;
    this.clearCoordsState() ; // If we're clearing the message, we definitely want the coords cleared
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
