module Bookings
  module Data
    class GiasDataFile
      EXPECTED_HEADER = '"URN","LA (code)","LA (name)","EstablishmentNumber","EstablishmentName"'.freeze
      EXPECTED_FIRST_ROW = %r(\A\d{3}\d+,).freeze
      TEMP_PATH = Rails.root.join('tmp', 'gias').freeze
      attr_reader :today

      def initialize
        @today = Time.zone.today.strftime('%Y%m%d')
      end

      def todays_file
        @todays_file ||= TEMP_PATH.join "edubase-#{today}.csv"
      end

      def remove_todays_file!
        Rails.logger.debug("Deleting todays edubase data")

        File.unlink todays_file
      end

      def remove_old_files!
        list_files.without(todays_file.to_s).each do |f|
          Rails.logger.debug("Deleting edubase data: #{f}")

          File.unlink f
        end
      end

      def path
        remove_old_files! # GC earlier files

        already_downloaded? ? todays_file : fetch_file
      end

      def source_url
        "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{today}.csv"
      end

      def valid_file?
        File.open(todays_file, 'r') do |f|
          unless f.readline.start_with? EXPECTED_HEADER
            raise InvalidSourceUri
          end

          unless f.readline.match? EXPECTED_FIRST_ROW
            raise InvalidSourceUri
          end
        end

        true
      rescue EOFError, InvalidSourceUri
        false
      end

      class InvalidSourceUri < RuntimeError; end

    private

      def list_files
        Dir[wildcard]
      end

      def wildcard
        TEMP_PATH.join('edubase-*.csv')
      end

      def create_temp_dir
        FileUtils.mkdir_p TEMP_PATH unless Dir.exist? TEMP_PATH
      end

      def already_downloaded?
        File.exist? todays_file
      end

      def fetch_file
        create_temp_dir

        download_and_save.tap do
          unless valid_file?
            remove_todays_file!
            raise InvalidSourceUri, "Invalid source URI: #{source_url}"
          end
        end
      end

      def download_and_save
        Rails.logger.debug("Downloading latest edubase data")

        File.open(todays_file, 'wb') do |f|
          f.write download_from_gias
        end

        todays_file
      end

      def download_from_gias
        Net::HTTP.get(parsed_source_uri)
      end

      def parsed_source_uri
        URI.parse source_url
      end
    end
  end
end
