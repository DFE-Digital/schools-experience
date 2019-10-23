module Bookings
  module Gitis
    module Store
      class Dynamics
        attr_reader :api

        def initialize(api)
          @api = api
        end

        def create_entity(entity_id, data)
          api.post(entity_id, data)
        end

        def update_entity(entity_id, data)
          api.patch(entity_id, data)
        end

        def find_one(entity_type, uuid, params)
          params['$select'] ||= entity_type.attributes_to_select

          entity_type.new api.get("#{entity_type.entity_path}(#{uuid})", params)
        end

        def find_many(entity_type, uuids, params)
          params['$filter'] = filter_by_uuid(entity_type.primary_key, uuids)
          params['$select'] ||= entity_type.attributes_to_select

          api.get(entity_type.entity_path, params)['value'].map do |entity_data|
            entity_type.new entity_data
          end
        end

        def fetch(entity_type, filter: nil, limit: 10, order: nil)
          params = {
            '$select' => entity_type.attributes_to_select,
            '$top' => limit
          }

          params['$filter'] = filter if filter.present?
          params['$orderby'] = order if order.present?

          records = api.get(entity_type.entity_path, params)['value']

          records.map do |record_data|
            entity_type.new(record_data)
          end
        end

      private

        def filter_by_uuid(key, uuids)
          uuids.map { |id| "#{key} eq '#{id}'" }.join(' or ')
        end
      end
    end
  end
end
