module Candidates
  module Registrations
    class RegistrationStep
      include ActiveModel::Model
      include ActiveModel::Attributes

      TIME_STAMPS = %w(created_at updated_at).freeze

      attribute :created_at, :datetime
      attribute :updated_at, :datetime

      attr_accessor :registration_session

      delegate :school, to: :registration_session

      # Attempts to populate a new registration_step with attributes from the
      # session.
      # Returns an unpersisted instance if no applicable attributes are found.
      def self.new_from_session(session)
        instance = new
        attributes_from_session = session.to_h.slice(*instance.attributes_to_persist.keys)
        created_at, updated_at = attributes_from_session.values_at(*instance.time_stamp_keys)
        attributes = attributes_from_session.except(*instance.time_stamp_keys).merge \
          'created_at' => created_at,
          'updated_at' => updated_at

        instance.assign_attributes attributes

        instance.registration_session = session

        instance
      end

      def attributes_to_persist
        attributes.except(*attributes_to_ignore).merge \
          created_at_session_key => created_at,
          updated_at_session_key => updated_at
      end

      def created_at_session_key
        "#{model_name.element}_created_at"
      end

      def updated_at_session_key
        "#{model_name.element}_updated_at"
      end

      def time_stamp_keys
        [created_at_session_key, updated_at_session_key]
      end

      def attributes_to_ignore
        TIME_STAMPS
      end

      def save
        unless registration_session
          fail <<~MSG.squish
            registration_session not set.
            Instantiate with `RegistrationSession#build_#{model_name.element}`
            to ensure registration_session is set
          MSG
        end

        return false unless valid?

        registration_session.save self

        self
      end

      def update(params)
        assign_attributes params
        save
      end

      def persisted?
        created_at.present?
      end

      def flag_as_persisted!
        validate!
        self.updated_at = DateTime.now
        self.created_at = self.updated_at unless persisted?
      end

      def ==(other)
        return false unless other.is_a? self.class

        other.attributes == self.attributes
      end
    end
  end
end
