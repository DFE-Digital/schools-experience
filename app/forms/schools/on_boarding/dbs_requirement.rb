module Schools
  module OnBoarding
    class DbsRequirement < Step
      include ActiveModel::Validations::Callbacks

      attribute :dbs_policy_conditions, :string
      attribute :dbs_policy_details, :string
      attribute :dbs_policy_details_inschool, :string
      attribute :no_dbs_policy_details, :string

      before_validation :ux_fix

      validates :dbs_policy_conditions, inclusion: Bookings::Profile::DBS_POLICY_CONDITIONS

      validates :dbs_policy_details, number_of_words: { less_than: 50 }, \
                                     if: -> { dbs_policy_details.present? }

      validates :dbs_policy_details_inschool, number_of_words: { less_than: 50 }, \
                                              if: -> { dbs_policy_details_inschool.present? }

      validates :no_dbs_policy_details, number_of_words: { less_than: 50 }, \
                                        if: -> { no_dbs_policy_details.present? }

      with_options if: -> { dbs_policy_conditions == 'required' } do
        validates :dbs_policy_details, presence: true
        validates :dbs_policy_details_inschool, absence: true
        validates :no_dbs_policy_details, absence: true
      end

      with_options if: -> { dbs_policy_conditions == 'inschool' } do
        validates :dbs_policy_details, absence: true
        validates :dbs_policy_details_inschool, presence: true
        validates :no_dbs_policy_details, absence: true
      end

      with_options if: -> { dbs_policy_conditions == 'notrequired' } do
        validates :dbs_policy_details, absence: true
      end

      def self.compose(dbs_policy_conditions, dbs_policy_details, no_dbs_policy_details, dbs_policy_details_inschool)
        new \
          dbs_policy_conditions: dbs_policy_conditions,
          dbs_policy_details: dbs_policy_details,
          dbs_policy_details_inschool: dbs_policy_details_inschool,
          no_dbs_policy_details: no_dbs_policy_details
      end

      def requires_check
        dbs_policy_conditions != 'notrequired'
      end

    private

      # Avoid showing the user a validation error is they have entered details
      # that are no longer applicable
      def ux_fix
        case dbs_policy_conditions
        when 'required'
          self.dbs_policy_details_inschool = self.no_dbs_policy_details = nil
        when 'inschool'
          self.dbs_policy_details = self.no_dbs_policy_details = nil
        when 'notrequired'
          self.dbs_policy_details = self.dbs_policy_details_inschool = nil
        end
      end
    end
  end
end
