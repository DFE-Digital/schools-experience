module Bookings::Gitis
  class Country
    include Entity

    self.entity_path = 'dfe_countries'

    entity_id_attribute :dfe_countryid
    entity_attribute :dfe_name

    def initialize(crm_data = {})
      crm_data = crm_data.stringify_keys

      self.dfe_countryid = crm_data['dfe_countryid']
      self.dfe_name = crm_data['dfe_name']

      super
    end
  end
end
