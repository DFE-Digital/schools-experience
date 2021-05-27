module Bookings::Gitis
  class TeachingSubject
    include Entity

    self.entity_path = 'dfe_teachingsubjectlists'

    entity_id_attribute :dfe_teachingsubjectlistid
    entity_attribute :dfe_name

    # Aliases to achieve parity with GetIntoTeachingApiClient::LookupItem
    alias_attribute :id, :dfe_teachingsubjectlistid
    alias_attribute :value, :dfe_name
  end
end
