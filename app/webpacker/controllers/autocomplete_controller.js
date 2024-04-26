import { Controller } from '@hotwired/stimulus'
import { Loader } from "@googlemaps/js-api-loader";
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
    await this.#initialiseService();

    this.element.addEventListener('submit', this.validateLocationField.bind(this));
  }

  async validateLocationField(event) {
    event.preventDefault();
    const form = event.currentTarget;
    const locationInput = document.getElementById('location-field');
    const locationFormGroup = document.querySelector('[data-autocomplete-target="locationFormGroup"]');
    let errorParagraph = locationFormGroup.querySelector('.govuk-error-message');

    if (locationInput.value.trim() === "") {
      if (!errorParagraph) {
        errorParagraph = document.createElement('p');
        errorParagraph.textContent = "Enter a location or postcode";
        errorParagraph.classList.add("govuk-error-message");

        const hiddenErrorMessage = document.createElement("span");
        hiddenErrorMessage.textContent = "Error:";
        hiddenErrorMessage.classList.add("govuk-visually-hidden");
        errorParagraph.prepend(hiddenErrorMessage);

        locationFormGroup.insertBefore(errorParagraph, locationFormGroup.querySelector('.govuk-body'));
        locationFormGroup.classList.add("govuk-form-group--error");

        this.createErrorSummary("Enter a location or postcode");
      }
    } else {
      if (errorParagraph) {
        errorParagraph.remove();
        locationFormGroup.classList.remove("govuk-form-group--error");
        this.removeErrorSummary("Enter a location or postcode");
      }
      form.submit();
    }
  }

  createErrorSummary(errorMessage) {
    const errorSummary = document.querySelector('.govuk-error-summary');
    const gridColumn = document.querySelector('.govuk-grid-column-two-thirds');
    if (!errorSummary) {
      const form = document.querySelector('.school-search-form');
      const errorSummaryHtml = `
        <div class="govuk-error-summary" data-module="govuk-error-summary">
          <div role="alert">
            <h2 class="govuk-error-summary__title">There is a problem</h2>
            <div class="govuk-error-summary__body">
              <ul class="govuk-list govuk-error-summary__list">
                <li><a href="#location-field">${errorMessage}</a></li>
              </ul>
            </div>
          </div>
        </div>
      `;
      gridColumn.insertAdjacentHTML('afterbegin', errorSummaryHtml);
    }
  }

  removeErrorSummary(errorMessage) {
    const errorSummary = document.querySelector('.govuk-error-summary');
    if (errorSummary) {
      errorSummary.remove();
    }
  }

  #showErrorMessage() {
    if (this.errorValue === "") return;

    this.locationFormGroupTarget.classList.add("govuk-form-group--error");

    const errorMessage = document.createElement("p");
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

  async #initialiseService() {
    const loader = new Loader({
      apiKey: this.apiKeyValue,
      libraries: ["places"],
    });

    const google = await loader.load();

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
