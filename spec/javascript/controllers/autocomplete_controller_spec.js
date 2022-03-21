import { Application } from "stimulus";
import AutocompleteController from "autocomplete_controller.js";

describe("AutocompleteController", () => {
  beforeAll(() => {
    const application = Application.start();
    application.register("autocomplete", AutocompleteController);
  });

  beforeEach(() => {
    clearHead();
    setupGoogleMock();
  });

  describe("connecting", () => {
    beforeEach(() => {
      setBody();
    });

    it("shows the section (after hiding it, to reduce content shift)", () => {
      const wrapper = document.getElementsByTagName("form")[0];

      expect(wrapper.style.visibility).toEqual("");
    });

    it("removes the non-JavaScript input", () => {
      expect(
        document.querySelector('[data-autocomplete-target="nonJsInput"]')
      ).toBeFalsy();
    });

    it("shows the autocomplete label", () => {
      expect(
        document.querySelector(
          '[data-autocomplete-target="autocompleteInputLabel"]'
        ).classList
      ).not.toContain("govuk-visually-hidden");
    });
  });

  describe("errors", () => {
    beforeEach(() => {
      setBody(true);
    });

    it("shows an GOV.UK error message", () => {
      const locationFormGroup = document.querySelector(
        '[data-autocomplete-target="locationFormGroup"]'
      );

      expect(locationFormGroup.classList).toContain("govuk-form-group--error");

      const errorMessage = locationFormGroup.getElementsByTagName("p")[0];
      const hiddenErrorMessage = errorMessage.getElementsByTagName("span")[0];

      expect(errorMessage.textContent).toEqual(
        "Error:Must be at least 2 characters"
      );
      expect(errorMessage.classList).toContain("govuk-error-message");
      expect(hiddenErrorMessage.classList).toContain("govuk-visually-hidden");
    });
  });

  const setBody = (errors = false) => {
    document.body.innerHTML = `
      <form class="school-search-form" id="new_" novalidate="novalidate" data-controller="autocomplete" data-autocomplete-target="wrapper" data-autocomplete-api-key-value="KEY" action="/candidates/schools" accept-charset="UTF-8" method="get">
        <div class="govuk-form-group">
          <label for="location-field" class="govuk-label">Enter location or postcode</label>
          <input id="location-field" class="govuk-input" required="required" minlength="2" type="search" data-autocomplete-target="nonJsInput" name="location">
        </div>

        <div class="govuk-form-group" data-autocomplete-target="locationFormGroup">
          <label for="location-autocomplete" data-autocomplete-target="autocompleteInputLabel" class="govuk-label govuk-visually-hidden">Enter location or postcode</label>
          <div id="location-autocomplete" data-autocomplete-target="autocompleteWrapper" class="govuk-body"></div>
        </div>

        <div class="school-search-form__submit">
          <div class="govuk-form-group">
            <button type="submit" formnovalidate="formnovalidate" class="govuk-button" data-module="govuk-button" data-prevent-double-click="true" aria-label="Search for schools offering school experience">Search</button>
          </div>
        </div>
      </form>
    `;

    if (errors) {
      const form = document.body.getElementsByTagName("form")[0];
      form.setAttribute(
        "data-autocomplete-error-value",
        "Must be at least 2 characters"
      );
    }
  };

  const setupGoogleMock = () => {
    global.window.google = {
      maps: {
        places: {
          AutocompleteService: jest.fn(),
          AutocompleteSessionToken: jest.fn(),
          PlacesServiceStatus: {
            INVALID_REQUEST: "INVALID_REQUEST",
            NOT_FOUND: "NOT_FOUND",
            OK: "OK",
            OVER_QUERY_LIMIT: "OVER_QUERY_LIMIT",
            REQUEST_DENIED: "REQUEST_DENIED",
            UNKNOWN_ERROR: "UNKNOWN_ERROR",
            ZERO_RESULTS: "ZERO_RESULTS",
          },
        },
      },
    };
  };

  const clearHead = () => {
    document.head.innerHTML = null;
  };
});
