module Schools
  module PlacementRequests
    class DummyRejection
      include ActiveModel::Model
      attr_accessor :reason
    end

    class RejectController < Schools::BaseController
      def new
        @placement_request = placement_request
        @reject_reason = DummyRejection.new
      end

      def create
        # blah
      end

    private

      def placement_request
        OpenStruct.new(
          candidate_name: "Robert Terwilliger"
        )
      end
    end
  end
end
