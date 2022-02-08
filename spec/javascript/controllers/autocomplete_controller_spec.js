import { Application } from "stimulus";
import AutocompleteController from "autocomplete_controller.js";

describe("SearchController", () => {
  beforeEach(async () => {
    setupGoogleMock();

    const application = Application.start();
    application.register("autocomplete", AutocompleteController);

    setBody();
    clearHead();
  });

  describe("connecting", () => {
    it("hides then shows the section to reduce content shift", async () => {
      const wrapper = document.getElementsByTagName("form")[0];

      expect(wrapper.style.visibility).toEqual("hidden");

      await mockGoogleScriptLoading();

      expect(wrapper.style.visibility).toEqual("");
    });

    it("inserts the Google Places API script", () => {
      expect(document.head.getElementsByTagName("script")[0].src).toEqual(
        "https://maps.googleapis.com/maps/api/js?key=KEY&libraries=places"
      );
    });

    it("initialises the autocomplete service", async () => {
      await mockGoogleScriptLoading();

      expect(
        global.window.google.maps.places.AutocompleteService
      ).toHaveBeenCalledTimes(1);
      expect(
        global.window.google.maps.places.AutocompleteSessionToken
      ).toHaveBeenCalledTimes(1);
    });

    it("applies GOV.UK styling to the autocomplete input", async () => {
      await mockGoogleScriptLoading();

      expect(document.getElementsByTagName("input")[0].classList).toContain(
        "govuk-input"
      );
    });

    it("removes the non-JavaScript input", async () => {
      expect(
        document.querySelector('[data-autocomplete-target="nonJsInput"]')
      ).toBeTruthy();

      await mockGoogleScriptLoading();

      expect(
        document.querySelector('[data-autocomplete-target="nonJsInput"]')
      ).toBeFalsy();
    });

    it("shows the autocomplete label", async () => {
      expect(
        document.querySelector(
          '[data-autocomplete-target="autocompleteInputLabel"]'
        ).classList
      ).toContain("govuk-visually-hidden");

      await mockGoogleScriptLoading();

      expect(
        document.querySelector(
          '[data-autocomplete-target="autocompleteInputLabel"]'
        ).classList
      ).not.toContain("govuk-visually-hidden");
    });
  });

  const setBody = () => {
    document.body.innerHTML = `
      <form class="school-search-form" id="new_" novalidate="novalidate" data-controller="autocomplete" data-autocomplete-target="wrapper" data-autocomplete-api-key-value="KEY" action="/candidates/schools" accept-charset="UTF-8" method="get">
        <div class="govuk-form-group">
          <label for="location-field" class="govuk-label">Enter location or postcode</label>
          <input id="location-field" class="govuk-input" required="required" minlength="2" type="search" data-autocomplete-target="nonJsInput" name="location">
        </div>

        <label for="location-autocomplete" data-autocomplete-target="autocompleteInputLabel" class="govuk-label govuk-visually-hidden">Enter location or postcode</label>
        <div id="location-autocomplete" data-autocomplete-target="autocompleteWrapper" class="govuk-body"></div>

        <div class="school-search-form__submit">
          <div class="govuk-form-group">
            <button type="submit" formnovalidate="formnovalidate" class="govuk-button" data-module="govuk-button" data-prevent-double-click="true" aria-label="Search for schools offering school experience">Search</button>
          </div>
        </div>
      </form>
    `;
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

  const mockGoogleScriptLoading = async () => {
    const googlePlacesScript = document.head.getElementsByTagName("script")[0];
    googlePlacesScript.dispatchEvent(new Event("load"));

    await new Promise(process.nextTick);
  };

  const clearHead = () => {
    document.head.innerHTML = null;
  };
});
