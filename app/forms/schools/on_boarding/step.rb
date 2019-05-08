module Schools
  module OnBoarding
    class Step
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.new_from_bookings_school(bookings_school)
        new FromBookingsSchool.new(bookings_school)[model_name.element]
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end
    end
  end
end
