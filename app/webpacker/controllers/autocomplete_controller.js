import { Controller } from "stimulus";
import accessibleAutocomplete from "accessible-autocomplete";

export default class extends Controller {
  #autocompleteService = null;
  #sessionToken = null;

  static targets = [
    "nonJsInput",
    "autocompleteWrapper",
    "autocompleteInputLabel",
    "wrapper",
    "locationFormGroup",
  ];

  static values = {
    apiKey: String,
    error: String,
  };

  async connect() {
    this.#setWrapperVisibility(false);

    this.#initialiseAutoComplete();
    this.#removeNonJsInput();
    this.#showAutoCompleteLabel();
    this.#showErrorMessage();

    this.#setWrapperVisibility(true);

    await this.#loadScript();
    this.#initialiseService();
  }

  #showErrorMessage() {
    if (this.errorValue === "") return;

    this.locationFormGroupTarget.classList.add("govuk-form-group--error");

    const errorMessage = document.createElement("span");
    errorMessage.textContent = this.errorValue;
    errorMessage.classList.add("govuk-error-message");

    const hiddenErrorMessage = document.createElement("span");
    hiddenErrorMessage.textContent = "Error:";
    hiddenErrorMessage.classList.add("govuk-visually-hidden");
    errorMessage.prepend(hiddenErrorMessage);

    this.locationFormGroupTarget.insertBefore(
      errorMessage,
      document.getElementById(this.autocompleteWrapperTarget.id)
    );
  }

  #findPredictions = (query, populateResults) => {
    this.#autocompleteService?.getPlacePredictions(
      {
        input: query,
        sessionToken: this.#sessionToken,
        componentRestrictions: {
          country: "UK",
        },
      },
      (predictions) => {
        const results = this.#formatPredictions(predictions);
        populateResults(results);
      }
    );
  };

  #formatPredictions(predictions) {
    if (predictions === null) return [];

    return predictions.map((prediction) =>
      prediction.description.replace(", UK", "")
    );
  }

  #removeNonJsInput() {
    // This input is needed to support users who have JavaScript turned off.
    document
      .getElementById(this.nonJsInputTarget.id)
      .closest(".govuk-form-group")
      .remove();
  }

  async #loadScript() {
    return new Promise((resolve) => {
      const script = document.createElement("script");
      script.src = `https://maps.googleapis.com/maps/api/js?key=${this.apiKeyValue}&libraries=places`;
      script.onload = resolve;
      document.head.append(script);
    });
  }

  #initialiseService() {
    this.#sessionToken = new google.maps.places.AutocompleteSessionToken();
    this.#autocompleteService = new google.maps.places.AutocompleteService();
  }

  #initialiseAutoComplete() {
    accessibleAutocomplete({
      element: document.getElementById("location-autocomplete"),
      id: this.nonJsInputTarget.id,
      name: this.nonJsInputTarget.name,
      source: this.#findPredictions,
      autoselect: true,
      displayMenu: "overlay",
      defaultValue: this.nonJsInputTarget.value,
    });
  }

  #showAutoCompleteLabel() {
    this.autocompleteInputLabelTarget.classList.remove("govuk-visually-hidden");
  }

  #setWrapperVisibility(visible) {
    // To reduce any shift as the page loads, hide the section on initialisation (which
    // maintains the space), then show it when loaded.
    this.wrapperTarget.style.visibility = visible ? "" : "hidden";
  }
}
