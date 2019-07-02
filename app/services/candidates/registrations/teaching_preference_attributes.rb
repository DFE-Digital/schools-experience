module Candidates
  module Registrations
    class TeachingPreferenceAttributes
      LEGACY_KEY = 'candidates_registrations_subject_preference'.freeze
      NEW_KEY = 'candidates_registrations_teaching_preference'.freeze

      def initialize(registration_session)
        @registration_session = registration_session
      end

      def attributes
        if teaching_preference_attributes?
          teaching_preference_attributes
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
          'teaching_stage',
          'subject_first_choice',
          'subject_second_choice',
          'created_at',
          'updated_at'
      end

      def teaching_preference_attributes?
        @registration_session.has_key? NEW_KEY
      end

      def teaching_preference_attributes
        @registration_session.fetch NEW_KEY
      end
    end
  end
end
