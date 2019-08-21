module Schools
  module DFESignInAPI
    class Client
      def self.enabled?
        [
          ENV['DFE_SIGNIN_API_CLIENT'],
          ENV['DFE_SIGNIN_API_SECRET'],
          ENV['DFE_SIGNIN_API_ENDPOINT']
        ].map(&:presence).all?
      end
    end
  end
end
