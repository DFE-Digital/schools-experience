module GitisAccess
  extend ActiveSupport::Concern

  included do
    class_attribute :use_gitis_cache
    self.use_gitis_cache = false
  end

  def gitis_crm
    Bookings::Gitis::Factory.crm read_from_cache: use_gitis_cache
  end
end
