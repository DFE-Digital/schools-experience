module Schools
  module DFESignInAPI
    class RoleCheckedOrganisations
      attr_reader :user_uuid

      def initialize(user_uuid)
        @user_uuid = user_uuid
      end

      def organisation_uuid_pairs
        @organisation_uuid_pairs ||=
          query_organisation_uuids
            .select(&method(:has_role?))
      end

      def organisation_urns
        organisation_uuid_pairs.values
      end

      def organisation_uuids
        organisation_uuid_pairs.keys
      end

    private

      def query_organisation_uuids
        Organisations.new(user_uuid).uuids
      end

      def has_role?(org_uuid, _org_urn)
        Roles.new(user_uuid, org_uuid).has_school_experience_role?
      end
    end
  end
end
