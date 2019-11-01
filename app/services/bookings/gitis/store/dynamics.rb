module Bookings
  module Gitis
    module Store
      class Dynamics
        attr_reader :api

        def initialize(token, service_url: nil, endpoint: nil)
          @api = API.new(token, service_url: service_url, endpoint: endpoint)
        end

        def find(entity_type, id_or_ids, **options)
          params = options.stringify_keys

          if !id_or_ids.is_a?(Array)
            validate_id! id_or_ids
            find_one entity_type, id_or_ids, params.merge('$top' => 1)
          elsif id_or_ids.any?
            id_or_ids.each(&method(:validate_id!))
            find_many entity_type, id_or_ids, params.merge('$top' => id_or_ids.length)
          else
            []
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

        def write(entity)
          fail ArgumentError, "entity must include Entity" unless entity.class < Entity
          return false unless entity.valid?

          if entity.id.blank?
            entity.entity_id = create_entity entity.entity_id, entity.attributes_for_create
          elsif entity.attributes_for_update.any?
            update_entity entity.entity_id, entity.attributes_for_update
          end

          entity.id
        end

      private

        def filter_by_uuid(key, uuids)
          uuids.map { |id| "#{key} eq '#{id}'" }.join(' or ')
        end

        def find_one(entity_type, uuid, params = {})
          params['$select'] ||= entity_type.attributes_to_select

          entity_type.new api.get("#{entity_type.entity_path}(#{uuid})", params)
        end

        def find_many(entity_type, uuids, params = {})
          return [] if uuids.empty?

          params['$filter'] = filter_by_uuid(entity_type.primary_key, uuids)
          params['$select'] ||= entity_type.attributes_to_select

          api.get(entity_type.entity_path, params)['value'].map do |entity_data|
            entity_type.new entity_data
          end
        end

        def create_entity(entity_id, data)
          api.post(entity_id, data)
        end

        def update_entity(entity_id, data)
          api.patch(entity_id, data)
        end

        def validate_id!(uuid)
          Entity.valid_id?(uuid) || fail(ArgumentError, "Invalid Entity Id")
        end
      end
    end
  end
end
