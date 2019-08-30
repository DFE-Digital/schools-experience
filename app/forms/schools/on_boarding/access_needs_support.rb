module Schools
  module OnBoarding
    class AccessNeedsSupport < Step
      attribute :supports_access_needs, :boolean

      validates :supports_access_needs, inclusion: [true, false]

      def self.compose(supports_access_needs)
        new supports_access_needs: supports_access_needs
      end
    end
  end
end
