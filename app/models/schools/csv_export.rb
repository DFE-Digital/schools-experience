require "csv"
require "academic_year"

module Schools
  class CsvExport
    MAX_IDS_IN_CRM_REQ = 50
    BATCH_SIZE = 300

    HEADER = %w[
      Id
      Name
      Email
      Date
      Duration
      Subject
      Status
      Attendance
    ].freeze

    attr_reader :school

    def self.column(title)
      HEADER.index(title)
    end

    def initialize(school)
      @school = school
    end

    def export
      generate
    end

    def filename
      today = Time.zone.today.to_formatted_s(:govuk)
      "School experience export (#{school.urn}) - #{today}.csv"
    end

  private

    def generate
      CSV.generate do |csv|
        csv << HEADER

        each_placement_requests_with_crm_data do |placement_request|
          csv << CsvExportRow.new(placement_request).row
        end
      end
    end

    def placement_requests
      school
        .placement_requests
        .includes(
          :candidate,
          :placement_date,
          { booking: :bookings_subject },
          :candidate_cancellation,
          :school_cancellation,
          :subject
        )
        .where(created_at: start_of_academic_year..)
        .order(created_at: :desc)
    end

    def each_placement_requests_with_crm_data(&block)
      placement_requests.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        batch.each_slice(MAX_IDS_IN_CRM_REQ) do |requests|
          contact_fetcher.assign_to_models(requests)

          requests.each(&block)
        end
      end
    end

    def start_of_academic_year
      AcademicYear.start_for_date Time.zone.now
    end

    def contact_fetcher
      @contact_fetcher ||= Bookings::Gitis::ContactFetcher.new
    end
  end
end
