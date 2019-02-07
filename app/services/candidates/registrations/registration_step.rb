module Candidates
  module Registrations
    class RegistrationStep
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :created_at, :datetime
      attribute :updated_at, :datetime

      def persisted?
        created_at.present?
      end

      # Flag the model as having being persisted
      def persisted!
        validate!
        self.updated_at = DateTime.now
        self.created_at = self.updated_at unless persisted?
      end
    end
  end
end
