module Schools
  module OnBoarding
    class DbsRequirement < Step
      include ActiveModel::Validations::Callbacks

      attribute :requires_check, :boolean
      attribute :dbs_policy_details, :string
      attribute :no_dbs_policy_details, :string

      before_validation :ux_fix

      validates :requires_check, inclusion: [true, false]

      validates :dbs_policy_details, number_of_words: { less_than: 50 }, \
                                     if: -> { dbs_policy_details.present? }

      validates :no_dbs_policy_details, number_of_words: { less_than: 50 }, \
                                        if: -> { no_dbs_policy_details.present? }

      with_options if: :requires_check do
        validates :dbs_policy_details, presence: true
        validates :no_dbs_policy_details, absence: true
      end

      with_options if: -> { requires_check == false } do
        validates :dbs_policy_details, absence: true
      end

      def self.compose(requires_check, dbs_policy_details, no_dbs_policy_details)
        new \
          requires_check: requires_check,
          dbs_policy_details: dbs_policy_details,
          no_dbs_policy_details: no_dbs_policy_details
      end

    private

      # Avoid showing the user a validation error is they have entered details
      # that are no longer applicable
      def ux_fix
        if requires_check
          self.no_dbs_policy_details = nil
        else
          self.dbs_policy_details = nil
        end
      end
    end
  end
end
