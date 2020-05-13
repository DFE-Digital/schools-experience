module Bookings
  module Data
    class SchoolMassImporter
      attr_accessor :existing_urns, :edubase_data, :email_override

      include EdubaseDataHelpers

      def initialize(edubase_data, email_override = nil)
        self.edubase_data = edubase_data
          .each
          .with_object({}) do |record, h|
            h[record['URN'].to_i] = record
          end

        self.email_override = email_override

        self.existing_urns = Bookings::School.pluck(:urn)
      end

      def import
        new_schools = edubase_data.reject { |urn, _| urn.in?(existing_urns) }

        Bookings::School.transaction do
          puts "importing schools..."
          Bookings::School.import(new_schools.map { |_, row| build_school(row) }.compact)

          puts "setting up phases..."
          new_schools.each.with_index do |(urn, row), i|
            if (i % 1000).zero?
              print '.'
            end

            school = Bookings::School.find_by(urn: urn)

            next if school.blank?

            assign_phases(school, row['PhaseOfEducation (code)'])
          end

          puts "done..."
        end
      end

    private

      def assign_phases(school, edubase_id)
        phases = map_phase(edubase_id.to_i)
        return if phases.nil?
        return if school.phases.any?

        school.phases << phases if school
      end

      def map_phase(edubase_id)
        # 0: Not applicable              -> ¯\_(ツ)_/¯
        # 1: Nursery                     -> Early years
        # 2: Primary                     -> Primary (4 to 11)
        # 3: Middle deemed primary       -> Primary (4 to 11)
        # 4: Secondary                   -> Secondary (11 to 16)
        # 5: Middle deemed secondary     -> Secondary (11 to 16)
        # 6: 16 plus                     -> 16 to 18
        # 7: All through                 -> Nursery + Primary + Secondary + College

        nursery   = phases['Early years']
        primary   = phases['Primary (4 to 11)']
        secondary = phases['Secondary (11 to 16)']
        college   = phases['16 to 18']

        {
          1 => nursery,
          2 => primary,
          3 => primary,
          4 => secondary,
          5 => secondary,
          6 => college,
          7 => [nursery, primary, secondary, college]
        }[edubase_id]
      end

      def phases
        @phases ||= Bookings::Phase.all.index_by(&:name)
      end

      def nilify(val)
        val.present? ? val.strip : nil
      end

      def cleanup_website(urn, url)
        return nil if url.blank?

        fail "invalid hostname for #{urn}, #{url}" unless url.split(".").size > 1

        # do nothing if starting with a valid protocol
        url_with_prefix = if url.starts_with?("http:", "https:")
                            url

                          # typos
                          elsif url.starts_with?("http;")
                            url.tr('http;', 'http:')

                          elsif url.starts_with?("Hhtp:")
                            url.tr('Hhtp:', 'http:')

                          # add a prefix if none present, most common error
                          else
                            "http://#{url}"
                          end

        # skip ip addresses
        return nil if url_with_prefix =~ /\d+\.\d+\.\d+\.\d+/

        # skip email addresses
        return nil if url_with_prefix =~ /@/

        # skip urls that don't look sensible
        unless url_with_prefix.match?(/^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,10}(:[0-9]{1,5})?(\/.*)?$/ix)
          puts "invalid website for #{urn}, #{url}"
          return nil
        end

        url_with_prefix.downcase
      end

      def build_school(edubase_row)
        attributes = {
          urn: nilify(edubase_row['URN']),
          name: nilify(edubase_row['EstablishmentName']),
          website: cleanup_website(edubase_row['URN'], edubase_row['SchoolWebsite']),
          contact_email: email_override.presence,
          address_1: nilify(edubase_row['Street']),
          address_2: nilify(edubase_row['Locality']),
          address_3: nilify(edubase_row['Address3']),
          town: nilify(edubase_row['Town']),
          county: nilify(edubase_row['County (name)']),
          postcode: nilify(edubase_row['Postcode']),
          coordinates: convert_to_point(edubase_row),
          bookings_school_type_id: school_types[edubase_row['TypeOfEstablishment (code)'].to_i].id
        }

        if attributes[:postcode].blank?
          puts "#{attributes[:urn]}: cannot import #{attributes[:name]}, missing postcode"
          return nil
        end

        if attributes[:address_1].blank?
          puts "#{attributes[:urn]}: cannot import #{attributes[:name]}, missing address_1"
          return nil
        end

        if attributes[:coordinates].blank?
          puts "#{attributes[:urn]}: cannot import #{attributes[:name]}, missing coordinates"
          return nil
        end

        attributes
      end
    end
  end
end
