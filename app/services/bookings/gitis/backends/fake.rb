module Bookings
  module Gitis
    module Backends
      class Fake
        def initialize(_api); end

        def create_entity(entity_id, data)
          return super unless stubbed?

          REQUIRED.each do |key|
            unless data.has_key?(key)
              raise "Bad Response - attribute '#{key}' is missing"
            end
          end

          data.keys.each do |key|
            unless ALLOWED.include?(key)
              raise "Bad Response - attribute '#{key}' is not recognised"
            end
          end

          "#{entity_id}(#{fake_contact_id})"
        end

        def update_entity(entity_id, data)
          return super unless stubbed?

          data.keys.each do |key|
            unless ALLOWED.include?(key)
              raise "Bad Response - attribute '#{key}' is not recognised"
            end
          end

          entity_id
        end
      end
    end
  end
end
