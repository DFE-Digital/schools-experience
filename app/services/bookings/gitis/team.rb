module Bookings::Gitis
  class Team
    include Entity

    self.entity_path = 'teams'

    entity_id_attribute :ownerid
    entity_attribute :name

    def initialize(crm_data = {})
      crm_data = crm_data.stringify_keys

      self.ownerid = crm_data['ownerid']
      self.name = crm_data['name']

      super
    end
  end
end
