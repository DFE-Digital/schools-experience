module GitisAccess
  extend ActiveSupport::Concern

  included do
    class_attribute :use_gitis_cache
    self.use_gitis_cache = false
  end

  def gitis_crm
    Bookings::Gitis::Factory.crm read_from_cache: use_gitis_cache
  end

  def assign_gitis_contacts(models)
    return models if models.empty?

    contact_uuids = models.map(&:contact_uuid)
    contacts = gitis_crm.find(contact_uuids).index_by(&:contactid)

    models.each do |model|
      model.gitis_contact = contacts[model.contact_uuid]
    end
  end
end
