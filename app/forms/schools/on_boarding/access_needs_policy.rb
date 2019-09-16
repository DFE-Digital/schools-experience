module Schools
  module OnBoarding
    class AccessNeedsPolicy < Step
      attribute :has_access_needs_policy, :boolean
      attribute :url, :string

      validates :has_access_needs_policy, inclusion: [true, false]
      validates :url, presence: true, if: :has_access_needs_policy
      validates :url, absence: true, unless: :has_access_needs_policy
      validates :url, format: URI::regexp(%w(http https)), if: -> { url.present? }
      validates :url, format: /\Ahttps?:\/\/.*/, if: -> { url.present? }

      def self.compose(has_access_needs_policy, url)
        new has_access_needs_policy: has_access_needs_policy, url: url
      end

      def valid?(*args)
        ux_fix
        super
      end

    private

      def ux_fix
        self.url = nil unless has_access_needs_policy
      end
    end
  end
end
