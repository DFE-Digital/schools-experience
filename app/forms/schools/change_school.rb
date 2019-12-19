module Schools
  class ChangeSchool
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id
    validates :id, presence: true

    def self.allow_school_change_in_app?
      [
        Rails.configuration.x.dfe_sign_in_api_enabled,
        Rails.configuration.x.dfe_sign_in_api_school_change_enabled
      ].all?
    end
  end
end
