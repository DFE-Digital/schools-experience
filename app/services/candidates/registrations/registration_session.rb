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

      def initialize(session)
        @registration_session = session
      end

      def save(model)
        model
          .tap { |m| m.registration_session = self.dup }
          .tap(&:flag_as_persisted!)
          .attributes_to_persist
          .except('urn') # TODO move this into attributes_to_ignore / remove this
          .each { |k, v| @registration_session[k] = v }
      end

      def fetch(klass)
        model = klass.new_from_session self.dup

        if model.persisted?
          model
        else
          # TODO remove this
          legacy_fetch!(klass).tap { |step| step.registration_session = self.dup }
        end
      end

      def fetch_attributes(klass, defaults = {})
        fetch(klass).attributes.to_h
      rescue StepNotFound
        defaults
      end

      RegistrationState::STEPS.each do |step|
        self.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{step}
            fetch #{step.to_s.classify}
          end

          def #{step}_attributes
            fetch_attributes #{step.to_s.classify}
          end

          def build_#{step}(params = {})
            #{step.to_s.classify}.new params.merge(registration_session: self)
          end
        RUBY
      end

      def uuid
        @registration_session['uuid'] ||= SecureRandom.urlsafe_base64
      end

      def flag_as_pending_email_confirmation!
        raise NotCompletedError unless all_steps_completed?

        @registration_session['status'] = PENDING_EMAIL_CONFIRMATION_STATUS
      end

      def pending_email_confirmation?
        @registration_session['status'] == PENDING_EMAIL_CONFIRMATION_STATUS
      end

      def flag_as_completed!
        @registration_session['status'] = COMPLETED_STATUS
      end

      def completed?
        @registration_session['status'] == COMPLETED_STATUS
      end

      # TODO add spec
      def email
        personal_information.email
      end

      def urn
        @registration_session.fetch 'urn'
      end

      def school
        @school ||= Candidates::School.find urn
      end

      def school_name
        school.name
      end

      def to_h
        @registration_session
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
          @registration_session.fetch(klass.model_name.param_key)
      rescue KeyError => e
        raise RegistrationSession::StepNotFound, e.key
      end
    end
  end
end
