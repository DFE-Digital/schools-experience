module Schools
  module OnBoarding
    class SchoolFee < Step
      AVAILABLE_INTERVALS = %w(Daily One-off).freeze

      attribute :amount_pounds, :decimal, scale: 2, precision: 4
      attribute :description, :string
      attribute :interval, :string
      attribute :payment_method, :string

      validates :amount_pounds, presence: true
      validates :amount_pounds, numericality: { greater_than: 0, less_than: 10000 }, if: -> { amount_pounds.present? }
      validates :description, presence: true
      validates :interval, presence: true
      validates :interval, inclusion: { in: AVAILABLE_INTERVALS }, if: -> { interval.present? }
      validates :payment_method, presence: true

      def self.compose(amount_pounds, description, interval, payment_method)
        new \
          amount_pounds: amount_pounds,
          description: description,
          interval: interval,
          payment_method: payment_method
      end

      def available_intervals
        AVAILABLE_INTERVALS
      end
    end
  end
end
