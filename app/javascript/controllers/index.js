import { Application } from "@hotwired/stimulus"

import AutocompleteController from "./autocomplete_controller"
import BackLinkController from "./back_link_controller"
import CollapsibleController from "./collapsible_controller"
import EducationFormController from "./education_form_controller"
import MapController from "./map_controller"
import PreventDoubleClickController from "./prevent_double_click_controller"
import SearchController from "./search_controller"

// Explicit registration replaces Shakapacker's require.context +
// definitionsFromContext. Identifiers match the names previously derived from
// the controller filenames, so existing data-controller="..." markup is
// unaffected.
export function startStimulus() {
  const application = Application.start()

  application.register("autocomplete", AutocompleteController)
  application.register("back-link", BackLinkController)
  application.register("collapsible", CollapsibleController)
  application.register("education-form", EducationFormController)
  application.register("map", MapController)
  application.register("prevent-double-click", PreventDoubleClickController)
  application.register("search", SearchController)

  return application
}
