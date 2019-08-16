module Bookings
  module Gitis
    module Store
      def self.load(*args)
        Dynamics.new(*args)
      end
    end
  end
end
