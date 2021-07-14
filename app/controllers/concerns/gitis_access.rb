module GitisAccess
  extend ActiveSupport::Concern

  def assign_gitis_contacts(models)
    return models if models.empty?

    Bookings::Gitis::ContactFetcher.new.assign_to_models(models)
  end

  def assign_gitis_contact(candidate)
    Bookings::Gitis::ContactFetcher.new.assign_to_model(candidate)
  end
end
