module Schools
  module OnBoarding
    class OtherFee
      include ActiveModel::Model
      include ActiveModel::Attributes

      def valid?
        false
      end
    end
  end
end
