module Bookings
  module Data
    class SchoolManager
      attr_accessor :urns

      def initialize(urns)
        self.urns = urns
      end

      def enable_urns
        set_enabled(true)
      end

      def disable_urns
        set_enabled(false)
      end

    private

      def set_enabled(new_status)
        Bookings::School.transaction do
          urns.each do |row|
            Bookings::School.find_by(urn: row['urn']).tap do |bs|
              fail "no school found with urn #{row['urn']}" if bs.blank?

              puts "Updating #{bs.name}, enabled: #{new_status}"
              if new_status
                bs.enable!
              else
                bs.disable!
              end
            end
          end
        end
      end
    end
  end
end
