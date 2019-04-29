module Schools
  module OnBoarding
    class Specialism < Step
      attribute :has_specialism, :boolean
      attribute :details, :string

      validates :has_specialism, inclusion: [true, false]
      validates :details, presence: true, if: :has_specialism

      def self.compose(has_specialism, details)
        new has_specialism: has_specialism, details: details
      end
    end
  end
end
