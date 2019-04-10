module Schools
  module OnBoarding
    class DBSFee
      include ActiveModel::Model
      include ActiveModel::Attributes

      def valid?
        false
      end
    end
  end
end
