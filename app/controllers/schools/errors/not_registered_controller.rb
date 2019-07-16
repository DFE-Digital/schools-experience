module Schools
  module Errors
    class NotRegisteredController < ApplicationController
      include DFEAuthentication

      def show; end
    end
  end
end
