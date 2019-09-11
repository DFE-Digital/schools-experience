# Standard GOVUK date format, use via `Date.tomorrow.to_formatted_s(:govuk)`
# https://design-system.service.gov.uk/components/date-input/
Date::DATE_FORMATS[:govuk] = "%d %B %Y"
Date::DATE_FORMATS[:gitis] = "%d/%m/%Y"
