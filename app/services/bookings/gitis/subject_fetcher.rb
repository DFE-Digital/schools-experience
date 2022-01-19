module Bookings
  module Gitis
    class SubjectFetcher
      class << self
        def teaching_subjects
          @teaching_subjects ||= begin
            api = GetIntoTeachingApiClient::LookupItemsApi.new
            api.get_teaching_subjects
          end
        end

        def api_subject_id_from_gitis_value(value)
          return nil if value.blank?

          teaching_subjects.find { |s| s.value == value }&.id
        end

        def api_subject_from_gitis_uuid(uuid)
          return nil if uuid.blank?

          teaching_subjects.find { |s| s.id == uuid }&.value
        end
      end
    end
  end
end
