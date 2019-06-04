module Schools
  module PlacementRequests
    class ReviewAndSendEmail
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :candidate_instructions

      validates :candidate_instructions, presence: true
    end
  end
end
