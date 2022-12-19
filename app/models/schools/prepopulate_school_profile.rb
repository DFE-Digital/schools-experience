module Schools
  class PrepopulateSchoolProfile
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :prepopulate_from_urn, :integer

    validates :prepopulate_from_urn, presence: true
    validates :prepopulate_from_urn, inclusion: { in: :available_school_urns }

    delegate :any?, to: :available_schools, prefix: true
    delegate :enabled?, to: :class

    class << self
      def enabled?
        [
          Rails.configuration.x.dfe_sign_in_api_enabled,
          Rails.configuration.x.dfe_sign_in_api_school_change_enabled
        ].all?
      end
    end

    def initialize(current_school, role_checked_uuids_to_urns, attributes = {})
      @current_school = current_school
      @uuids_to_urns = role_checked_uuids_to_urns

      super(attributes)
    end

    def available_schools
      @available_schools ||=
        Bookings::School.where(urn: organisation_urns)
          .includes(:profile)
          .where.not(urn: @current_school.urn)
          .select(&:onboarded?)
          .sort_by(&:name)
    end

    def prepopulate!
      other_school = Bookings::School.find_by(urn: prepopulate_from_urn)

      @current_school.school_profile = other_school.school_profile.dup
      @current_school.school_profile.save!
    end

  private

    def organisation_urns
      @uuids_to_urns.values
    end

    def available_school_urns
      available_schools.map(&:urn)
    end
  end
end
