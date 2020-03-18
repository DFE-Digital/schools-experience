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

    Bookings::Gitis::ContactFetcher \
      .new(gitis_crm)
      .assign_to_models(models)
  end

  def assign_gitis_contact(candidate)
    Bookings::Gitis::ContactFetcher \
      .new(gitis_crm)
      .assign_to_model(candidate)
  end
end
