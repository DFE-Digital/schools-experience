module Schools
  class ChangeSchool
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :current_user, :uuids_to_urns

    attribute :urn, :integer
    validates :urn, presence: true
    validates :urn, inclusion: { in: :organisation_urns }, if: -> { urn.present? }
    validate :validate_user_has_role_at_school, if: -> { urn.present? }

    delegate :role_check_enabled?, to: Schools::DFESignInAPI::Client

    def self.allow_school_change_in_app?
      [
        Rails.configuration.x.dfe_sign_in_api_enabled,
        Rails.configuration.x.dfe_sign_in_api_school_change_enabled
      ].all?
    end

    def initialize(current_user, uuids_to_urns, attributes = {})
      @current_user   = current_user
      @uuids_to_urns  = uuids_to_urns

      super attributes
    end

    def urn=(school_urn)
      @_current_school = nil
      super
    end

    def retrieve_valid_school!
      validate!
      Bookings::School.find_by!(urn: urn)
    end

    def available_schools
      Bookings::School.ordered_by_name.where(urn: organisation_urns)
    end

    def uuid
      urns_to_uuids[urn]
    end

    class InaccessibleSchoolError < StandardError; end

  private

    def organisation_urns
      uuids_to_urns.values
    end

    def user_has_role_at_school?
      return true unless role_check_enabled?

      role_checker.has_school_experience_role?
    rescue Faraday::ResourceNotFound
      # if the role isn't found the API returns a 404 - this means that the user
      # has insufficient privileges but this *isn't* really an error, so log it
      # and return false
      Rails.logger.warn("Role query yielded 404, uuid: #{user_uuid}, urn: #{urn}")

      false
    end

    def role_checker
      Schools::DFESignInAPI::Roles.new current_user[:dfe_sign_in_user_uuid], uuid
    end

    def urns_to_uuids
      @uuids_to_urns.invert
    end

    def validate_user_has_role_at_school
      unless user_has_role_at_school?
        errors.add :urn, :missing_dfe_signin_role
      end
    end
  end
end
