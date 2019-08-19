module Bookings::Gitis
  class TeachingSubject
    include Entity

    self.entity_path = 'dfe_teachingsubjectlists'

    entity_id_attribute :dfe_teachingsubjectlistid
    entity_attribute :dfe_name

    def initialize(crm_data = {})
      crm_data = crm_data.stringify_keys

      self.dfe_teachingsubjectlistid = crm_data['dfe_teachingsubjectlistid']
      self.dfe_name = crm_data['dfe_name']

      super
    end
  end
end
