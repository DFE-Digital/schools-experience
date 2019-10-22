import { initAll, Accordion } from "govuk-frontend";
initAll();

import "@stimulus/polyfills"
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import { descriptionSummary, descriptionToggleEvent } from 'analytics/school_description_helper.js';
import { sendGAEvent } from 'analytics/send_ga_event';

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

Accordion.prototype.originalSetExpanded = Accordion.prototype.setExpanded;
Accordion.prototype.setExpanded = function (expanded, $section) {
  const eventName = this.$module.attributes['data-track-event-name'];

  if (eventName) {
    const segment = $section.querySelector('button').id;

    if (expanded && !$section.classList.contains(this.sectionExpandedClass)) {
      sendGAEvent(eventName, segment, 'open');
    }
    else if (!expanded && $section.classList.contains(this.sectionExpandedClass)) {
      sendGAEvent(eventName, segment, 'closed');
    }
  }

  this.originalSetExpanded(expanded, $section);
};

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
