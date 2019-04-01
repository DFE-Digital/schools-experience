module Schools
  module OnBoarding
    class PhasesList
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :primary, :boolean, default: false
      attribute :secondary, :boolean, default: false
      attribute :college, :boolean, default: false

      validates :primary, inclusion: [true, false]
      validates :secondary, inclusion: [true, false]
      validates :college, inclusion: [true, false]

      validate :at_least_one_phase_offered

      def self.compose(primary, secondary, college)
        new primary: primary, secondary: secondary, college: college
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end

    private

      def at_least_one_phase_offered
        errors.add(:base, :no_phase_offered) unless at_least_one_phase_offered?
      end

      def at_least_one_phase_offered?
        [primary, secondary, college].any?
      end
    end
  end
end
