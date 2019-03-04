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
    let location = new Microsoft.Maps.Location(
      this.data.get('latitude'),
      this.data.get('longitude')
    ) ;

    this.map = new Microsoft.Maps.Map(this.containerTarget, {
        credentials: this.data.get('apiKey'),
        mapTypeId: Microsoft.Maps.MapTypeId.road,
        center: location,
        animate: true,
        showDashboard: true,
        enableSearchLogo: false,
        enableClickableLogo: false,
        showCopyright: true
    }) ;

    let pin = new Microsoft.Maps.Pushpin(location);
    this.map.entities.push(pin) ;

    if (this.data.has('title')) {
      let box = { title: this.data.get('title') }

      if (this.data.has('description'))
        box.description = this.data.get('description') ;

      var infobox = new Microsoft.Maps.Infobox(location, box);
      infobox.setMap(this.map) ;
    }
  }
}
