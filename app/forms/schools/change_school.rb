module Schools
  class ChangeSchool
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :current_user, :organisation_uuids

    attribute :urn
    validates :urn, presence: true

    def self.allow_school_change_in_app?
      [
        Rails.configuration.x.dfe_sign_in_api_enabled,
        Rails.configuration.x.dfe_sign_in_api_school_change_enabled
      ].all?
    end

    def initialize(current_user, organisation_uuids, attributes = {})
      @current_user       = current_user
      @organisation_uuids = organisation_uuids

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

    class InaccessibleSchoolError < StandardError; end

  private

    def organisation_urns
      organisation_uuids.values
    end
  end
end
