module Candidates
  module Registrations
    class EducationAttributes
      LEGACY_KEY = 'candidates_registrations_subject_preference'.freeze
      NEW_KEY = 'candidates_registrations_education'.freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def attributes
        if education_attributes?
          education_attributes
        elsif legacy_attributes?
          converted_legacy_attributes
        end
      end

    private

      def legacy_attributes?
        @registration_session.has_key? LEGACY_KEY
      end

      def legacy_attributes
        @registration_session.fetch LEGACY_KEY
      end

      def converted_legacy_attributes
        legacy_attributes.slice \
          'degree_stage',
          'degree_stage_explaination',
          'degree_subject',
          'created_at',
          'updated_at'
      end

      def education_attributes?
        @registration_session.has_key? NEW_KEY
      end

      def education_attributes
        @registration_session.fetch NEW_KEY
      end
    end
  end
end
