module Bookings::Gitis
  module FakeAuth
    def initialize(client_id: nil, client_secret: nil, tenant_id: nil, service_url: nil)
      Rails.application.config.x.fake_crm || super
    end

    def token
      stubbed? ? 'my.fake.token' : super
    end

  private

    def stubbed?
      Rails.application.config.x.fake_crm
    end
  end
end
