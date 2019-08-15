module Bookings
  module Gitis
    module Backends
      def self.load(*args)
        Dynamics.new(*args)
      end
    end
  end
end
