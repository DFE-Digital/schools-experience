import { initAll } from "govuk-frontend"
import "@stimulus/polyfills"
import "custom-event-polyfill"
import dfeAutocomplete from "dfe-autocomplete"

import { startStimulus } from "./controllers"

initAll()

startStimulus()

dfeAutocomplete({
  rawAttribute: true
})
