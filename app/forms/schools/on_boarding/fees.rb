module Schools
  module OnBoarding
    class Fees < Step
      attribute :selected_fees, default: []

      validate :fees_or_none_selected

      def self.compose(administration_fees, dbs_fees, other_fees)
        selected_fees = []
        selected_fees << "administration_fees" if administration_fees
        selected_fees << "dbs_fees" if dbs_fees
        selected_fees << "other_fees" if other_fees

        unless [administration_fees, dbs_fees, other_fees].all?(&:nil?)
          selected_fees << "none" if !administration_fees && !dbs_fees & !other_fees
        end

        new(selected_fees: selected_fees)
      end

      def administration_fees?
        selected_fees.include?("administration_fees")
      end

      def dbs_fees?
        selected_fees.include?("dbs_fees")
      end

      def other_fees?
        selected_fees.include?("other_fees")
      end

      def none?
        selected_fees.include?("none")
      end

    private

      def fees_or_none_selected
        no_options_selected = !none? && !administration_fees? && !dbs_fees? && !other_fees?
        fees_and_no_fees_selected = none? && (administration_fees? || dbs_fees? || other_fees?)

        if no_options_selected || fees_and_no_fees_selected
          errors.add(:selected_fees, :no_fees_selected)
        end
      end
    end
  end
end
