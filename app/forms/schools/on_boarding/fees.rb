module Schools
  module OnBoarding
    class Fees < Step
      attribute :administration_fees, :boolean
      attribute :dbs_fees, :boolean
      attribute :other_fees, :boolean

      validates :administration_fees, inclusion: [true, false]
      validates :dbs_fees, inclusion: [true, false]
      validates :other_fees, inclusion: [true, false]

      def self.compose(administration_fees, dbs_fees, other_fees)
        new \
          administration_fees: administration_fees,
          dbs_fees: dbs_fees,
          other_fees: other_fees
      end

      def administration_fees?
        administration_fees
      end

      def dbs_fees?
        dbs_fees
      end

      def other_fees?
        other_fees
      end
    end
  end
end
