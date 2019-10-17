module Candidates
  module Registrations
    class RegistrationStep
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :urn, :integer
      attribute :created_at, :datetime
      attribute :updated_at, :datetime

      def school
        return nil unless urn.present?

        @school ||= Candidates::School.find(urn)
      end

      def completed?
        valid?
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
