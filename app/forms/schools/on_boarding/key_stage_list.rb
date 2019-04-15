module Schools
  module OnBoarding
    class KeyStageList
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :early_years, :boolean, default: false
      attribute :key_stage_1, :boolean, default: false
      attribute :key_stage_2, :boolean, default: false

      validate :at_least_one_key_stage_offered

      def self.compose(early_years, key_stage1, key_stage2)
        new \
          early_years: early_years,
          key_stage_1: key_stage1,
          key_stage_2: key_stage2
      end

      def ==(other)
        other.respond_to?(:attributes) && other.attributes == self.attributes
      end

    private

      def at_least_one_key_stage_offered
        unless at_least_one_key_stage_offered?
          errors.add :base, :no_key_stage_offered
        end
      end

      def at_least_one_key_stage_offered?
        [early_years, key_stage_1, key_stage_2].any?
      end
    end
  end
end
