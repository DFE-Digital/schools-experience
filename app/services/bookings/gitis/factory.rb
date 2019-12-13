module Bookings
  module Gitis
    class Factory
      class << self
        def crm; new.crm; end
        alias_method :gitis, :crm
      end

      def crm
        if Rails.application.config.x.gitis.fake_crm
          Bookings::Gitis::FakeCrm.new
        else
          Bookings::Gitis::CRM.new store
        end
      end

      def token
        Bookings::Gitis::Auth.new.token
      end

      def store
        Bookings::Gitis::Store::Dynamics.new token
      end
    end
  end
end
