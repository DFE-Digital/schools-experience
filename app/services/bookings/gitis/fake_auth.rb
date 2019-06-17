module Bookings::Gitis
  module FakeAuth
    def initialize(client_id: nil, client_secret: nil, tenant_id: nil, service_url: nil); end

    def token
      'my.stub.token'
    end
  end
end
