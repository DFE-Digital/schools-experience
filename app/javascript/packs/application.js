import { initAll, Accordion } from "govuk-frontend";
initAll();

import "@stimulus/polyfills";
import "custom-event-polyfill";
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import { logAccordionToggle } from 'analytics/log_accordion_toggle';

// Various top level code sets analytics so add global helper
import { CookiePreferences } from 'cookie_preferences' ;
global.cookie_allowed = CookiePreferences.allowed ;

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
  const eventName = this.$module.attributes.id;

  // the button inserted by the accordion plugin that replaces the
  // provided span and takes its descriptive ID
  const sectionName = $section.querySelector('.govuk-accordion__section-content').id;

  if (eventName && sectionName) {
    const accordionExpanded = new CustomEvent('accordionToggle', {
      bubbles: true,
      detail: {
        name: eventName.value,
        section: sectionName,
        expanded: expanded
      }
    });

    $section.dispatchEvent(accordionExpanded);
  }

  this.originalSetExpanded(expanded, $section);
};

// attach the listener to the outer accordion to catch messages bubbling
// up from its segments
if (CookiePreferences.allowed('analytics')) {
  document.querySelectorAll('.govuk-accordion').forEach((accordion) => {
    accordion.addEventListener('accordionToggle', (e) => {
      logAccordionToggle(e.detail.name, e.detail.section, e.detail.expanded ? 'open' : 'closed');
    });
  });
}

global.preventDoubleClick = function(form) {
  let buttons = form.querySelectorAll('input[type=submit],button[type=submit]') ;

  for (let button of buttons) {
    button.setAttribute('disabled', true) ;
  }

  return true ;
};
