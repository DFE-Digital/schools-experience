module Bookings
  module Data
    class SchoolUpdater
      BATCH_SIZE = 1000

      ATTRIBUTE_MAPPING = {
        name: 'EstablishmentName',
        address_1: 'Street',
        address_2: 'Locality',
        address_3: 'Address 3',
        town: 'Town',
        county: 'County (name)',
        postcode: 'Postcode'
      }.freeze

      include EdubaseDataHelpers

      attr_accessor :edubase_data

      def initialize(edubase_data)
        self.edubase_data = edubase_data
          .each
          .with_object({}) do |record, h|
            h[record['URN'].to_i] = record
          end
      end

      def update
        Bookings::School.eager_load(:school_type).find_each(batch_size: BATCH_SIZE) do |school|
          Bookings::School.transaction do
            row = edubase_data[school.urn]

            next if row.nil?
            next if matches?(school, row)

            school.update!(build_attributes(row))
            Event.create(bookings_school: school, event_type: 'school_edubase_data_refreshed')
          end
        end
      end

    private

      def matches?(school, row)
        [
          attributes_match?(school, row),
          coords_match?(school, row),
          school_types_match?(school, row)
        ].all?
      end

      def attributes_match?(school, row)
        ATTRIBUTE_MAPPING.map { |k, v| school.send(k).presence == row[v].presence }.all?
      end

      def coords_match?(school, row)
        school.coordinates == convert_to_point(row)
      end

      def school_types_match?(school, row)
        school.school_type.edubase_id == retrieve_school_type(row)
      end

      def build_attributes(row)
        # create an attributes hash using ATTRIBUTE_MAPPING
        # the key being the attribute in Bookings::Schools and
        # the value being extracted from the row using the edubase identifier
        #
        # So, with an ATTRIBUTE_MAPPING of { name: 'EstablishmentName' } a
        # CSV in the following format:
        #
        # EstablishmentName,...
        # "Some School",...
        #
        # Will be converted to:
        # { name: 'Some School' }
        #
        attributes = ATTRIBUTE_MAPPING.each_with_object({}) do |(k, v), h|
          h[k] = row[v]
        end

        # In addition to the directly-mappable attributes we also need
        # to assign a school type and convert its coordinates
        attributes.tap do |att|
          att.merge(coordinates: convert_to_point(row))
          att.merge(school_type_id: school_types[row[retrieve_school_type(row)]])
        end
      end
    end
  end
end
