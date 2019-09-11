module Bookings::Gitis
  class Country
    include Entity

    self.entity_path = 'dfe_countries'

    entity_id_attribute :dfe_countryid
    entity_attribute :dfe_name

    def self.default
      Rails.application.config.x.gitis.country_id
    end
  end
end
