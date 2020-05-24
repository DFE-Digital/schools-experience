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

    this.map = new google.maps.Map(this.containerTarget, {
        mapTypeId: 'roadmap',
        center: location,
        gestureHandling: 'none',
        zoomControl: false,
        mapTypeControl: true,
        scaleControl: true,
        streetViewControl: false,
        rotateControl: false,
        fullscreenControl: true
    }) ;

    let pin = new google.maps.Marker({
      position: location,
      map: this.map
    }) ;

    if (this.data.has('title')) {
      let content = '<div id="content">'+
        '<h1 id="firstHeading" class="firstHeading">' + this.data.get('title') + '</h1>'+
        '<div id="bodyContent">'+
          '<p>' + this.data.get('description') + '</p>' +
        '</div>' +
      '</div>';

      let infowindow = new google.maps.InfoWindow({
        content: content
      });

      pin.addListener('click', function() {
        infowindow.open(map, pin);
      });
    }
  }
}
