import { initAll } from "govuk-frontend";
initAll();

import "@stimulus/polyfills"
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import { descriptionSummary, descriptionToggleEvent } from 'analytics/school_description_helper.js';

const application = Application.start()
const context = require.context("controllers", true, /.js$/)
application.load(definitionsFromContext(context))

global.mapsLoadedCallback = function() {
  global.mapsLoaded = true ;

  let maps = document.querySelectorAll('[data-controller="map"]') ;
  for(let map of maps) {
    let instance = application.getControllerForElementAndIdentifier(map, "map");
    instance.initMap() ;
  }
}

window.descriptionTracker = {
  element: descriptionSummary,
  event: descriptionToggleEvent
};

global.preventDoubleClick = function(form) {
  let buttons = form.querySelectorAll('input[type=submit],button[type=submit]') ;

  for (let button of buttons) {
    button.setAttribute('disabled', true) ;
  }

  return true ;
}
