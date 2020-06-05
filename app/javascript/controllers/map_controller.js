import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['container'] ;
  map = null ;

  connect() {
    this.initMap() ;
  }

  initMap() {
    if (!global.mapsLoaded || this.map)
      return ;

    this.drawMap() ;
  }

  drawMap() {
    let location = new google.maps.LatLng(
      this.data.get('latitude'),
      this.data.get('longitude')
    ) ;

    let map = new google.maps.Map(this.containerTarget, {
        mapTypeId: 'roadmap',
        center: location,
        gestureHandling: 'none',
        zoomControl: true,
        mapTypeControl: true,
        scaleControl: false,
        streetViewControl: false,
        rotateControl: false,
        fullscreenControl: true,
        zoom: 17
    }) ;

    this.map = map;

    let pin = new google.maps.Marker({
      position: location,
      map: this.map
    }) ;

    if (this.data.has('title')) {
      let content = '<p class="govuk-!-font-size-14">'+
          '<strong class="govuk-!-font-weight-bold">' + this.data.get('title') + '</strong><br/>' + this.data.get('description') + '</p>';

      let infowindow = new google.maps.InfoWindow({
        content: content
      });

      function openInfoWidow() {
        infowindow.open(map, pin);
      }

      pin.addListener('click', openInfoWidow);

      openInfoWidow();
    }
  }
}
