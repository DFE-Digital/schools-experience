module Schools
  module OnBoarding
    class AdministrationFee
      include ActiveModel::Model
      include ActiveModel::Attributes

      def valid?
        false
      end
    end
  end
end
