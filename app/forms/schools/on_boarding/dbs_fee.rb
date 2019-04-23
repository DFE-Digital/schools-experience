module Schools
  module OnBoarding
    class DBSFee < SchoolFee
      attribute :interval, :string, default: 'One-off'.freeze

      validate :interval_is_one_off

    private

      def interval_is_one_off
        unless interval == 'One-off'.freeze
          errors.add :interval, "must be 'One-off'"
        end
      end
    end
  end
end
