module Bookings
  module Data
    class GiasReconciler
      BATCH_SIZE = 1000

      # Finds schools that have been on-boarded but are now
      # marked as closed according to the latest GIAS data.
      def identify_onboarded_closed
        closed_urns = []

        data_in_batches do |batch|
          closed_urns += batch
            .filter(&method(:close_date))
            .map(&method(:urn))
        end

        Bookings::School.onboarded.where(urn: closed_urns)
      end

      # If a school has been closed and re-opened (as an academy, for example)
      # then this will attempt to identify the new/matching school urns in the
      # latest GIAS data.
      def find_reopened_urns(closed_urns)
        open_urns = {}
        closed_urn_keys = {}

        data_in_batches do |batch|
          batch.each do |row|
            urn = urn(row)
            key = key(row)

            open_urns[key] ||= []
            open_urns[key] << urn unless close_date(row)
            closed_urn_keys[urn] = key if urn.in?(closed_urns)
          end
        end

        closed_urn_keys.transform_values { |k| open_urns[k] }
      end

    private

      def key(row)
        "#{row['LA (code)']}/#{row['EstablishmentNumber']}-#{row['LA (name)']}"
      end

      def urn(row)
        row["URN"].to_i
      end

      def close_date(row)
        row["CloseDate"].presence
      end

      def gias_data_file
        Bookings::Data::GiasDataFile.new.path
      end

      def data_in_batches
        rows = []

        CSV.foreach(gias_data_file, headers: true, encoding: "ISO-8859-1:UTF-8") do |row|
          rows << row

          if rows.length >= BATCH_SIZE
            yield rows
            rows = []
          end
        end

        yield rows if rows.any?
      end
    end
  end
end
