module Schools
  module OnBoarding
    class PhasesList
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :primary, :boolean, default: false
      attribute :secondary, :boolean, default: false
      attribute :college, :boolean, default: false
      attribute :secondary_and_college, :boolean, default: false

      validates :primary, inclusion: [true, false]
      validates :secondary, inclusion: [true, false]
      validates :college, inclusion: [true, false]
      validates :secondary_and_college, inclusion: [true, false]

      validate :at_least_one_phase_offered

      def self.compose(primary, secondary, college, secondary_and_college)
        new \
          primary: primary,
          secondary: secondary,
          college: college,
          secondary_and_college: secondary_and_college
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end

      def primary?
        primary
      end

      def secondary?
        secondary || secondary_and_college
      end

      def college?
        college || secondary_and_college
      end

    private

      def at_least_one_phase_offered
        errors.add(:base, :no_phase_offered) unless at_least_one_phase_offered?
      end

      def at_least_one_phase_offered?
        [primary?, secondary?, college?].any?
      end
    end
  end
end
