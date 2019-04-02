module Schools
  class BaseController < ApplicationController
    include DFEAuthentication
    before_action :require_auth

    def current_school
      @current_school ||= School.from_json SAMPLE_SCHOOL_JSON
    end

    # https://github.com/DFE-Digital/login.dfe.profile/blob/9948fc80984f44efb1df84f54a8559b7c9b4c2b3/test/unit/app/addOrganisation/review.get.test.js#L17
    SAMPLE_SCHOOL_JSON = <<-JSON.freeze
      {
        "id": "org1",
        "name": "organisation one",
        "category": {
          "id": "001",
          "name": "Establishment"
        },
        "type": {
          "id": "44",
          "name": "Academy Special Converter"
        },
        "urn": "356127",
        "uid": null,
        "ukprn": "123456789",
        "establishmentNumber": "3535",
        "status": {
          "id": 1,
          "name": "Open"
        },
        "closedOn": null,
        "address": null
      }
    JSON
  end
end
