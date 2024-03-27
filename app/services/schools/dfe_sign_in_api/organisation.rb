module Schools
  module DFESignInAPI
    class Organisation < Organisations
      attr_accessor :current_school_urn

      def initialize(user_uuid, current_school_urn)
        super(user_uuid)
        self.current_school_urn = current_school_urn
      end

      def current_organisation
        organisations.find { |org| org['urn'].to_i == current_school_urn }
      end

      def current_organisation_ukprn
        current_organisation['ukprn'] if current_organisation
      end

      def current_organisation_id
        current_organisation['id'] if current_organisation
      end
    end
  end
end
