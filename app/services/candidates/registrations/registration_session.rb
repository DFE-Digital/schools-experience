# Simple wrapper around Rails session.
# Encapsulates storing and retrieving registration wizard models from the
# session.
module Candidates
  module Registrations
    class RegistrationSession
      class NotCompletedError < StandardError; end
      class StepNotFound < StandardError; end

      PENDING_EMAIL_CONFIRMATION_STATUS = 'pending_email_confirmation'.freeze
      COMPLETED_STATUS = 'completed'.freeze

      def initialize(data)
        @data = data
      end

      def save(model)
        model
          .tap(&:flag_as_persisted!)
          .attributes_to_persist
          .except('urn')
          .each { |k, v| @data[k] = v }
      end

      def fetch(klass)
        model = klass.new_from_session @data.dup

        if model.persisted?
          model.tap { |m| m.urn = self.urn }
        else
          legacy_fetch!(klass).tap { |m| m.urn = self.urn }
        end
      end

      def fetch_attributes(klass, defaults = {})
        fetch(klass).attributes.to_h
      rescue StepNotFound
        defaults
      end

      # TODO SE-1877 remove this
      def legacy_session?
        fetch_attributes(PlacementPreference).key? 'bookings_placement_date_id'
      end

      RegistrationState::STEPS.each do |step|
        self.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{step}
            fetch #{step.to_s.classify}
          end

          def #{step}_attributes
            fetch_attributes #{step.to_s.classify}
          end
        RUBY
      end

      # TODO SE-1877 remove this
      def subject_and_date_information
        if legacy_session?
          attributes = fetch_attributes PlacementPreference
          SubjectAndDateInformation.new \
            attributes.slice "bookings_placement_date_id"
        else
          fetch SubjectAndDateInformation
        end
      end

      # NOTE
      # This is a special case as we need to pass in a school to limit
      # the available subject choices.
      def teaching_preference
        fetch(TeachingPreference).tap { |tp| tp.school = school }
      end

      def uuid
        @data['uuid'] ||= SecureRandom.urlsafe_base64
      end

      def flag_as_pending_email_confirmation!
        raise NotCompletedError unless all_steps_completed?

        @data['status'] = PENDING_EMAIL_CONFIRMATION_STATUS
      end

      def pending_email_confirmation?
        @data['status'] == PENDING_EMAIL_CONFIRMATION_STATUS
      end

      def flag_as_completed!
        @data['status'] = COMPLETED_STATUS
      end

      def completed?
        @data['status'] == COMPLETED_STATUS
      end

      # TODO add spec
      def email
        personal_information.email
      end

      def urn
        @data.fetch 'urn'
      end

      def school
        @school ||= Candidates::School.find urn if urn.present?
      end

      def school_name
        school.name
      end

      def to_h
        @data
      end

      def to_json(*args)
        to_h.to_json(*args)
      end

      def ==(other)
        # Ensure dates are compared correctly
        other.to_json == self.to_json
      end

    private

      def all_steps_completed?
        RegistrationState.new(self).completed?
      end

      def legacy_fetch!(klass)
        klass.new \
          @data.fetch(klass.model_name.param_key)
      rescue KeyError => e
        raise RegistrationSession::StepNotFound, e.key
      end
    end
  end
end
