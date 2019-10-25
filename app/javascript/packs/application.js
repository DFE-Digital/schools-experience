import { initAll, Accordion } from "govuk-frontend";
initAll();

import "@stimulus/polyfills";
import "custom-event-polyfill";
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import { logAccordionToggle } from 'analytics/log_accordion_toggle';

const application = Application.start();
const context = require.context("controllers", true, /.js$/);
application.load(definitionsFromContext(context));

global.mapsLoadedCallback = function() {
  global.mapsLoaded = true ;

  let maps = document.querySelectorAll('[data-controller="map"]') ;
  for(let map of maps) {
    let instance = application.getControllerForElementAndIdentifier(map, "map");
    instance.initMap() ;
  }
};

Accordion.prototype.originalSetExpanded = Accordion.prototype.setExpanded;
Accordion.prototype.setExpanded = function (expanded, $section) {
  // the name of the accordion as it will be categorised in GA
  const eventName = this.$module.attributes['data-track-event-name'];

  // the button inserted by the accordion plugin that replaces the
  // provided span and takes its descriptive ID
  const sectionButton = $section.querySelector('button');

  if (eventName && sectionButton) {
    const accordionExpanded = new CustomEvent('accordionToggle', {
      bubbles: true,
      detail: {
        name: eventName.value,
        section: sectionButton.id,
        expanded: expanded
      }
    });

    $section.dispatchEvent(accordionExpanded);
  }

  this.originalSetExpanded(expanded, $section);
};

window.logAccordionToggle = logAccordionToggle;

global.preventDoubleClick = function(form) {
  let buttons = form.querySelectorAll('input[type=submit],button[type=submit]') ;

  for (let button of buttons) {
    button.setAttribute('disabled', true) ;
  }

  return true ;
};
