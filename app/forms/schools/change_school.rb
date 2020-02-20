module Schools
  class ChangeSchool
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :current_user, :organisation_uuids

    attribute :id
    validates :id, presence: true

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

    def id=(school_id)
      @_current_school = nil
      super
    end

    def retrieve_valid_school!
      validate!
      Bookings::School.find(id)
    end

    def available_schools
      Bookings::School.ordered_by_name.where(urn: urns)
    end

    class InaccessibleSchoolError < StandardError; end

  private

    def urns
      organisation_uuids.values
    end
  end
end
