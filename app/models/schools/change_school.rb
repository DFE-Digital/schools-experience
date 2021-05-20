module Schools
  class ChangeSchool
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :current_user, :uuids_to_urns

    attribute :change_to_urn, :integer
    validates :change_to_urn, presence: true
    validates :change_to_urn,
      inclusion: { in: :organisation_urns },
      if: -> { change_to_urn.present? }

    class << self
      def allow_school_change_in_app?
        [
          Rails.configuration.x.dfe_sign_in_api_enabled,
          Rails.configuration.x.dfe_sign_in_api_school_change_enabled
        ].all?
      end

      def request_approval_url
        Rails.configuration.x.dfe_sign_in_request_organisation_url
      end
    end

    def initialize(current_user, role_checked_uuids_to_urns, attributes = {})
      @current_user   = current_user
      @uuids_to_urns  = role_checked_uuids_to_urns

      super attributes
    end

    def retrieve_valid_school!
      validate!
      Bookings::School.find_by!(urn: change_to_urn)
    end

    def available_schools
      Bookings::School.ordered_by_name.where(urn: organisation_urns)
    end

    def school_uuid
      urns_to_uuids[change_to_urn]
    end

    def user_uuid
      current_user.sub
    end

    def task_count_for_urn(_urn)
      3
    end

    class InaccessibleSchoolError < StandardError; end

  private

    def organisation_urns
      uuids_to_urns.values
    end

    def urns_to_uuids
      uuids_to_urns.invert
    end
  end
end
